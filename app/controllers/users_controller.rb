class UsersController < ApplicationController
  def settings
    @user = current_user
    authorize @user
  end
end
