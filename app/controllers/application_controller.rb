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

  def after_sign_out_path_for(resource_or_scope)
    flash[:notice] = "À bientôt, reviens vite donner des nouvelles !"
    new_user_session_path
  end

  private

  def skip_pundit?
    devise_controller? || params[:controller] =~ /(^(rails_)?admin)|(^pages$)/
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[first_name last_name address phone_number username birth_date])

    devise_parameter_sanitizer.permit(:account_update, keys: %i[first_name last_name address phone_number username birth_date])
  end

  # Récupère les derniers messages envoyés ou reçus par l'utilisateur courant, groupés par contact.
  def last_messages_by_contact
    Message
    .where("sender_id = :user_id OR receiver_id = :user_id", user_id: current_user.id)
    .includes(:contact, contact: :relationship) # on inclut tout ici, ça servira plus tard
    .group_by(&:contact_id)
    .transform_values { |msgs| msgs.max_by(&:created_at) }
  end

  # Retourne le message reçu le plus prioritaire selon l'ancienneté et la proximité.
  def main_message

  # Derniers messages reçus non ignorés par l'utilisateur courant.
  received_messages = last_messages_by_contact.values.select do |msg|
    msg.receiver_id == current_user.id &&
    (msg.dismissed == false || msg.dismissed.nil?)
  end

  # Sélectionne le message reçu ayant la priorité la plus élevée, calculée selon la proximité de la relation du contact et l'ancienneté du message.
  prioritized_message = received_messages
    .map { |msg|
      proximity = msg.contact.relationship.proximity || 1
      hours_since_received = ((Time.current - msg.created_at) / 1.hour).to_f
      priority_score = hours_since_received * proximity
      [msg, priority_score]
    }
    .max_by { |_, score| score }
    &.first

  prioritized_message
end


  def quick_messages
    # On récupère les derniers messages envoyés par contact
    sent_messages = last_messages_by_contact.values.select do |msg|
      msg.sender_id == current_user.id
    end

    # Trie les messages par ancienneté croissante puis par proximité décroissante.
    # On prend les 3 premiers messages après le tri.
    # La proximité est inversée pour que les contacts les plus proches soient prioritaires.
    prioritized = sent_messages
      .sort_by { |msg| [msg.created_at, -(msg.contact.relationship.proximity || 1)] }
      .first(3)

    prioritized
  end
  def default_url_options
    { host: ENV["DOMAIN"] || 'localhost:3000' }
  end
end
