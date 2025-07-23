class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @user = current_user
    @badges = policy_scope(@user.badges)
    @main_message = main_message
  end

  private

  # Retourne le message reçu le plus prioritaire selon l'ancienneté et la proximité.
  def main_message
    received_messages = current_user.messages.where(status: :received, dismissed: [false, nil])

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
end
