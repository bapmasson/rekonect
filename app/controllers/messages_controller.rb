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
      redirect_to messages_path, notice: "Réponse envoyée avec succès."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def message_params
    params.require(:message).permit(:content, :contact_id)
  end
end
