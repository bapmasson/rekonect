class MessagesController < ApplicationController
  # cette route ne sera pas utilisée (on utilisera pages#dashboard) mais je l'ai mise pour pouvoir se logger!
  def index
      @messages = policy_scope(Message)
  end
end
