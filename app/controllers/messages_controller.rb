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

  private

  def message_params
    params.require(:message).permit(:content, :contact_id)
  end
end
