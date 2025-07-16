class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :relationship
  has_many :messages

  # nom obligatoire
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  # notes, max 1000 caractère, autorise le champ vide avec allow blank true
  validates :notes, length: { maximum: 1000 }, allow_blank: true

  # date de dernier contact  et empeche une date future, peut être vide
  validates :last_interaction_at, allow_blank: true, comparison: { less_than_or_equal_to: Date.today }

  # valide les fks
  validates :user, presence: true
  validates :relationship, presence: true
end
