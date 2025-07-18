class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  include Pundit::Authorization
  before_action :configure_permitted_parameters, if: :devise_controller?


  # Pundit: allow-list approach

  # J'ai modifié les except: et only: pour ne pas avoir de bug de policy non définie car rails 7.1 vérifiait le contrôleur de Devise avant de lire l'exception.... ce qui amenait à l'écran rouge de policy non définie
  after_action :verify_authorized, if: -> { action_name != 'index' && !skip_pundit? }

  after_action :verify_policy_scoped, if: -> { action_name == 'index' && !skip_pundit? }


  # Redirect to the root path if the user is not authorized
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  def user_not_authorized
    flash[:alert] = "You are not authorized to perform this action."
    redirect_to(root_path)
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name address phone_number username birth_date])

    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name address phone_number username birth_date])
  end
end
