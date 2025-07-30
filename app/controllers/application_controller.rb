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

  # Retourne le message reçu le plus prioritaire selon l'ancienneté et la proximité.
  def main_message
    received_messages = Message.where(receiver_id: current_user.id, status: :received, dismissed: [false, nil])

    # La priorité est calculée comme le produit du temps écoulé (en heures) depuis la réception du message et de la proximité du contact.
    # Le message avec le score le plus élevé est retourné.
    prioritized_message = received_messages
      .includes(:contact)
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
    sent_messages = Message.where(sender_id: current_user.id, status: :sent).includes(:contact)

    # Pour chaque contact, ne garder que le dernier message envoyé
    latest_by_contact = sent_messages.group_by { |msg| msg.contact_id }.map { |_, msgs| msgs.max_by(&:created_at) }

    # Trie les messages par ancienneté croissante puis par proximité décroissante.
    # On prend les 3 premiers messages après le tri.
    # La proximité est inversée pour que les contacts les plus proches soient prioritaires.
    prioritized = latest_by_contact
      .sort_by { |msg| [msg.created_at, -(msg.contact.relationship.proximity || 1)] }
      .first(3)

    prioritized
end
end
