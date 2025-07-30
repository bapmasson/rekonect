class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @badges = policy_scope(@user.badges)
    @main_message = main_message
    @quick_messages = quick_messages
    @sent_messages = current_user.sent_messages
    @received_messages = current_user.received_messages
  end
end
