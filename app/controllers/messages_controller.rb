class MessagesController < ApplicationController
  before_action :authenticate_user!

  # cette route ne sera pas utilisée (on utilisera pages#dashboard) mais je l'ai mise pour pouvoir se logger!
  def index
      @messages = policy_scope(Message)
  end

  def new
    @message = Message.new
    authorize @message
  end

  # Route pour répondre à un message en attente de réponse
  # Elle permet de générer une suggestion de réponse via l'API OpenAI et d'afficher un résumé des derniers échanges
  # entre l'utilisateur et le contact du message.
  def reply
    @message = Message.find(params[:id])
    authorize @message
    last_messages = current_user.messages.where(contact_id: @message.contact_id).order(updated_at: :desc).last(3)
    @summary = message_summary(last_messages)
    ai_suggestion(@message, @summary) if @message.ai_draft.blank? && @message.status != "draft_by_ai"
  end

  # Route pour "rekonecter" un contact, c'est-à-dire relancer la conversation avec une suggestion de réponse
  # Elle génère une suggestion de réponse basée sur les derniers messages échangés avec le contact.
  # Elle affiche également un résumé des derniers échanges pour aider l'utilisateur à se remémorer le contexte.
  def rekonect
    @message = Message.find(params[:id])
    authorize @message
    last_messages = current_user.messages.where(contact_id: @message.contact_id).order(updated_at: :desc).last(3)
    @summary = message_summary(last_messages)
    @new_message = Message.new(contact: @message.contact, user: current_user)
    rekonect_suggestion(@new_message, @summary)
  end

  def create
    @message = current_user.messages.build(message_params)
    authorize @message
    if @message.save
      redirect_to messages_path, notice: "Message envoyé avec succès."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def awaiting_answer
    @messages = current_user.messages.where(status: :draft_by_ai)
    authorize @messages
  end

  def show
    @message = Message.find(params[:id])
    authorize @message
  end

  def edit
    @message = Message.find(params[:id])
    authorize @message
  end

  def dismiss_suggestion
    @message = current_user.messages.find(params[:id])
    authorize @message
    @message.update(dismissed: true)
    redirect_to messages_path # <-- redirige vers la liste des messages
  end

  def update
    @message = Message.find(params[:id])
    authorize @message
    if @message.update(user_answer: params[:message][:user_answer], status: :sent, sent_at: Time.current)
      redirect_to dashboard_path, notice: "Réponse envoyée avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :contact_id)
  end

  def message_summary(messages)
    cache_key = "message_summary_#{messages.map(&:id).join('_')}"
    summary = Rails.cache.read(cache_key)
    return summary if summary.present?

    # Utilise l'API OpenAI pour générer un résumé des derniers messages
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
              "#{messages.first&.contact&.name} and the user #{messages.first&.user&.first_name}. " \
              "Speak directly to the user : " \
              "#{messages.map { |m| "message de #{m.contact.name}: #{m.content}#{m.user_answer.present? ? ", réponse utilisateur: #{m.user_answer}" : ""}" }.join(", ")}"
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
    # Utilise l'API OpenAI pour générer une suggestion de réponse
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
    # Utilise l'API OpenAI pour générer une suggestion de relance
    client = OpenAI::Client.new
    chatgpt_response = client.chat(
      parameters: {
        model: "gpt-4o-mini",
        messages: [
          { role: "system", content: "You are a helpful assistant that generates messages." },
          { role: "user", content: "It has been a long time since you last wrote to #{message.contact.name}. This is the background of the conversation: #{summary}. Generate in French a warmful message of 50 words max to recreate a conversation with this contact without repeating the summary as it is meant only for you and not for being in the reply." }
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
