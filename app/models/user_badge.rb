class UserBadge < ApplicationRecord
  belongs_to :user
  belongs_to :badge
  # valider la presence pour la foreinkey

  validates :user, presence: true
  validates :badge, presence: true

  # date d'obtention obligatoire et pas dans le futur

  validates :obtained_at, presence: true, comparison: { less_than_or_equal_to: Date.today }

  # Badge donné une fois par user

  validates :badge_id, uniqueness: { scope: :user_id, message: "Ce badge vous a déjà été attribué." }
end
