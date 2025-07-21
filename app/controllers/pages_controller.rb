class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @awaiting_message = current_user.messages.where(status: :draft_by_ai, dismissed: [false, nil]).first
    end
  end
end
