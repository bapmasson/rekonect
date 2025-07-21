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

  def dismiss_suggestion
    @message = current_user.messages.find(params[:id])
    authorize @message
    # On marque le message comme "ignoré" (par exemple, ajoute un statut ou un champ dismissed)
    @message.update(dismissed: true)
    redirect_to root_path
  end

  private

  def message_params
    params.require(:message).permit(:content, :contact_id)
  end
end
