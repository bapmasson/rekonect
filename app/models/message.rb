class Message < ApplicationRecord
  belongs_to :contact
  belongs_to :conversation
  belongs_to :sender, class_name: "User"
  belongs_to :receiver, class_name: "User"
  after_create_commit :broadcast_message

  # contenu taille min 1, max 2000
  # conditions similaires pour la suggestion IA et la réponse utilisateur
  # Allow blank est en true car aucun champ n'est obligatoire mais il faudra un des trois pour que le message soit créé
  validates :content, length: { minimum: 1, maximum: 2000 }, allow_blank: true
  validates :ai_draft, length: { minimum: 1, maximum: 2000 }, allow_blank: true

  # Validation perso pour être sûrs qu'au moins un champ entre content, ai_draft et user_answer soit rempli pour
  # pouvoir créer un message
  validate :content_or_ai_draft_or_user_answer_present

  # Date d’envoi optionnelle, pas dans le futur, peut être blanc
  # validates :sent_at, allow_blank: true, comparison: { less_than_or_equal_to: Date.today }

  validates :sender, presence: true
  validates :receiver, presence: true

  # enum statut (workflow IA suggestion)
  # sent == message envoyé par un contact ou apr l'utilisateur
  # draft_by_ai == suggestion par IA faite et stockée dans la colonne ai_draft
  enum status: { sent: 0, draft_by_ai: 1 }

  private

  # On vérifie qu'au moins un champ soit rempli sinon erreur
  def content_or_ai_draft_or_user_answer_present
    if [content, ai_draft].all?(&:blank?)
      errors.add(:base, "Please provide content, an AI draft" )
    end
  end

  def broadcast_message
    broadcast_append_to "conversation_#{conversation.id}_messages",
                        partial: "messages/message",
                        locals: { message: self },
                        target: "messages"
  end
end
