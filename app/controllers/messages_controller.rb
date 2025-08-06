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
      xp_context = Message.where(sender: current_user, contact_id: @conversation.contact_id).count == 0 ? :first_message : :rekonect
      @xp_gained = current_user.add_contextual_xp(xp_context)
      flash[:level_up] = true if current_user.leveled_up?
      respond_to do |format|
        format.turbo_stream do
          render turbo_stream: turbo_stream.append(:messages, partial: "messages/message",
            locals: { message: @message })
        end
        format.html { redirect_to conversation_path(@conversation) }
      end
    else
      redirect_to conversations_show_path(@conversation), status: :unprocessable_entity
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
      current_user.add_contextual_xp(:ai_reply)
      flash[:level_up] = true if current_user.leveled_up?
      redirect_to success_messages_path, notice: "Bravo, tu t’es Rekonect avec succès ! 🚀"
    else
      redirect_to reply_message_path(@message), alert: "Erreur lors de l’envoi de la réponse."
    end
  end

  def success
  end

  private

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
          { role: "system", content: "You are a helpful assistant that summarizes conversations between two people." },
          {
            role: "user",
            content:
              "Make a very short recap (80 words max) in French of each interaction between " \
              "#{messages.first&.contact&.name} and the user #{current_user.first_name}. " \
              "The user is #{current_user.first_name} and the recap will only be read by him. Speak directly to him, don't use his name at all: " \
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
          { role: "user", content: "You are #{current_user.first_name}. This is the background of the conversation with #{message.contact.name}: #{summary}. This is the last message you received : #{message.content}. It was sent #{message.created_at} and today is #{Time.current}. Generate in French a warm reply of 50 words max to this last message without repeating the summary as it is meant only for you and not for being in the reply. Take into account that some time has passed and the context may have changed." }
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
          { role: "user", content: "You are #{current_user.first_name}. Last time you wrote to #{message.contact.name} was #{message.created_at} and today is #{Time.current}. This is the background of the conversation between you two: #{summary}. This is the last message you sent : #{message.content}. It was the last message between you two. Generate in French a warm message of 50 words max to recreate a conversation with this contact without repeating the summary as it is meant only for you and not for being in the reply. Keep in mind that some time has passed since your last message so the context may have changed." }
        ]
      }
    )
    ai_suggestion = chatgpt_response["choices"][0]["message"]["content"] if chatgpt_response && chatgpt_response["choices"].any?
    message.update!(ai_draft: ai_suggestion, status: :draft_by_ai) if ai_suggestion.present?
    rescue StandardError => e
      Rails.logger.error("OpenAI API error: #{e.message}")
      "Unable to generate suggestion at this time."
  end

  def set_message
    @message = Message.find(params[:id])
    authorize @message
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Message introuvable."
  end
end
