class Message < ApplicationRecord
  belongs_to :user
  belongs_to :contact

  # contenu taille min 1, max 2000
  # conditions similaires pour la suggestion IA et la réponse utilisateur
  # Allow blank est en true car aucun champ n'est obligatoire mais il faudra un des trois pour que le message soit créé
  validates :content, length: { minimum: 1, maximum: 2000 }, allow_blank: true
  validates :ai_draft, length: { minimum: 1, maximum: 2000 }, allow_blank: true
  validates :user_answer, length: { minimum: 1, maximum: 2000 }, allow_blank: true

  # Validation perso pour être sûrs qu'au moins un champ entre content, ai_draft et user_answer soit rempli pour
  # pouvoir créer un message
  validate :content_or_ai_draft_or_user_answer_present

  # Date d’envoi optionnelle, pas dans le futur, peut être blanc
  validates :sent_at, allow_blank: true, comparison: { less_than_or_equal_to: Date.today }

  validates :user, presence: true
  validates :contact, presence: true

  # enum statut (workflow IA suggestion)
  # received == message reçu du contact, contenu stocké dans la colonne content
  # draft_by_ai == suggestion par IA faite et stockée dans la colonne ai_draft
  # sent == réponse de l'utilisateur envoyée au contact
  enum status: { received: 0, draft_by_ai: 1, sent: 2 }

  private

  # On vérifie qu'au moins un champ soit rempli sinon erreur
  def content_or_ai_draft_or_user_answer_present
    if [content, ai_draft, user_answer].all?(&:blank?)
      errors.add(:base, "Content, or AI Draft or User answer must be filled" )
    end
  end
end
