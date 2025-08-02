class MessagesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_message, only: [:show, :edit, :update, :send_message, :reply, :rekonect]
  before_action :reply_rekonect, only: [:reply, :rekonect]
  skip_after_action :verify_authorized, only: [:success]

  def index
    @messages = policy_scope(Message)
    authorize @messages
    @awaiting_messages = @messages.where.not(sender_id: current_user.id)
                          .select do |msg|
                            Message.where(conversation_id: msg.conversation_id)
                            .order(created_at: :desc)
                            .first == msg
                          end
    @contacts = current_user.contacts
    @sent_messages = current_user.sent_messages
    @received_messages = current_user.received_messages
    @conversations = Conversation.where("user1_id = ? OR user2_id = ?", current_user.id, current_user.id)
  end

  def new
    @message = Message.new
    authorize @message
  end

  def reply
    ai_suggestion(@message, @summary) if @message.ai_draft.blank? && @message.status != "draft_by_ai"
  end

  def rekonect
    rekonect_suggestion(@message, @summary) if @message.ai_draft.blank? && @message.status != "draft_by_ai"
  end

  def create
    @conversation = Conversation.find(params[:message][:conversation_id])
    @message = Message.new(
      conversation: @conversation,
      sender: current_user,
      receiver: @conversation.user1_id == current_user.id ? @conversation.user2 : @conversation.user1,
      content: params[:message][:content],
      contact_id: @conversation.contact_id
    )
    authorize @message
    if @message.save
      ChatChannel.broadcast_to(
        @conversation,
        render_to_string(partial: "messages/message", locals: { message: @message })
      )
      redirect_to conversation_path(@conversation), notice: "Message envoyé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def awaiting_answer
    @messages = Message.where(sender_id: current_user.id, status: :draft_by_ai)
    authorize @messages
  end

  def show
  end

  def edit
    @conversation = @message.conversation
    @history_messages = history_messages(@message)
    @summary = message_summary(@history_messages)
  end

  def dismiss_suggestion
    @message = Message.where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id).find(params[:id])
    authorize @message
    @message.update(dismissed: true)
    redirect_to messages_path
  end

  def update
    if @message.update(user_answer: params[:message][:user_answer], status: :sent, sent_at: Time.current)
      redirect_to success_messages_path, notice: "Bravo, tu t’es Rekonect avec succès ! 🚀"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def send_message
    if @message.update(user_answer: @message.ai_draft, status: :sent, sent_at: Date.current)
      redirect_to success_messages_path, notice: "Bravo, tu t’es Rekonect avec succès ! 🚀"
    else
      redirect_to reply_message_path(@message), alert: "Erreur lors de l’envoi de la réponse."
    end
  end

  def success
  end

  private

  def set_message
    @message = Message.find(params[:id])
    authorize @message
  end

  def message_params
    params.require(:message).permit(:content, :contact_id)
  end

  def reply_rekonect
    @conversation = @message.conversation
    @history_messages = history_messages(@message)
    @summary = message_summary(@history_messages)
  end

  def history_messages(message)
    Message.where(contact_id: message.contact_id)
      .where.not(id: message.id)
      .where("sender_id = ? OR receiver_id = ?", current_user.id, current_user.id)
      .order(created_at: :desc)
      .limit(3)
  end

  def message_summary(messages)
    cache_key = "message_summary_#{messages.map(&:id).join('_')}"
    summary = Rails.cache.read(cache_key)
    return summary if summary.present?

    client = OpenAI::Client.new
    chatgpt_response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a helpful assistant that summarizes conversations." },
          {
            role: "user",
            content:
              "Make a very short recap (80 words max) in French of each interaction between " \
              "#{messages.first&.contact&.name} and the user #{current_user.first_name}. " \
              "The user is #{current_user.first_name}. Speak directly to him, don't use his name: " \
              "#{messages.map { |m| "date d'envoi: #{m.created_at}, message de #{m.sender_id == current_user.id ? current_user.first_name : m.contact.name}: #{m.content}" }.join(", ")}"
          }
        ]
      }
    )
    summary = chatgpt_response["choices"][0]["message"]["content"] if chatgpt_response && chatgpt_response["choices"].any?
    summary ||= "Unable to generate summary at this time."
    Rails.cache.write(cache_key, summary, expires_in: 12.hours)
    summary
  rescue StandardError => e
    Rails.logger.error("OpenAI API error: #{e.message}")
    "Unable to generate summary at this time."
  end

  def ai_suggestion(message, summary)
    client = OpenAI::Client.new
    chatgpt_response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a helpful assistant that generates message replies." },
          { role: "user", content: "This is the background of the conversation: #{summary}. This is the last message you received : #{message.content}. Generate in French a warmful reply of 50 words max to this last message without repeating the summary as it is meant only for you and not for being in the reply." }
        ]
      }
    )
    ai_suggestion = chatgpt_response["choices"][0]["message"]["content"] if chatgpt_response && chatgpt_response["choices"].any?
    message.update!(ai_draft: ai_suggestion, status: :draft_by_ai) if ai_suggestion.present?
    rescue StandardError => e
      Rails.logger.error("OpenAI API error: #{e.message}")
      "Unable to generate suggestion at this time."
  end

  def rekonect_suggestion(message, summary)
    client = OpenAI::Client.new
    chatgpt_response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a helpful assistant that generates messages." },
          { role: "user", content: "It has been a long time since you last wrote to #{message.contact.name}. This is the background of the conversation: #{summary}. This is the last message you sent : #{message.content}. Generate in French a warmful message of 50 words max to recreate a conversation with this contact without repeating the summary as it is meant only for you and not for being in the reply." }
        ]
      }
    )
    ai_suggestion = chatgpt_response["choices"][0]["message"]["content"] if chatgpt_response && chatgpt_response["choices"].any?
    message.update!(ai_draft: ai_suggestion, status: :draft_by_ai) if ai_suggestion.present?
    rescue StandardError => e
      Rails.logger.error("OpenAI API error: #{e.message}")
      "Unable to generate suggestion at this time."
  end
end
