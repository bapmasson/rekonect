class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @badges = policy_scope(@user.badges)
    @main_message = main_message
    @quick_messages = quick_messages
  end
end
