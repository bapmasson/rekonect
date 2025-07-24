class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: [ :home ]

  def home
    if user_signed_in?
      @main_message = main_message
      @quick_messages = quick_messages
      @quick_messages ||= []
      else
      @main_message = nil
      @quick_messages = []
    end
  end
end
