class ChatController < ApplicationController
  skip_after_action :verify_policy_scoped, only: :index
  before_action :authenticate_user!

  def index
    @sent_messages = current_user.sent_messages
    @received_messages = current_user.received_messages
    @conversations = Conversation.where("user1_id = ? OR user2_id = ?", current_user.id, current_user.id)
  end
end
