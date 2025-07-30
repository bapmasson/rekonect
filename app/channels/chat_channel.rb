class ChatChannel < ApplicationCable::Channel
  def subscribed
    @conversation = Conversation.find(params[:conversation_id])
    stream_for @conversation
  end

  def receive(data)
    # Ici, tu peux créer le message et diffuser le HTML
  end
end
