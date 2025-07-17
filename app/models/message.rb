class Message < ApplicationRecord
  belongs_to :user
  belongs_to :contact

  # contenu obligatoire, min 1, max 2000
  validates :content, presence: true, length: { minimum: 1, maximum: 2000 }

  # conditions similaires pour la suggestion IA et la réponse utilisateur mais elles ne sont pas obligatoires
  validates :ai_draft, length: { minimum: 1, maximum: 2000 }
  validates :user_answer, length: { minimum: 1, maximum: 2000 }

  # Date d’envoi optionnelle, pas dans le futur, peut être blanc
  validates :sent_at, allow_blank: true, comparison: { less_than_or_equal_to: Date.today }

  validates :user, presence: true
  validates :contact, presence: true

  # enum statut (workflow IA suggestion)
  enum status: { draft: 0, suggested: 1, sent: 2, archived: 3 }
end
