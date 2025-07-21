class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :relationship
  has_many :messages
  has_one_attached :photo

  # nom obligatoire
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  # notes, max 1000 caractère, autorise le champ vide avec allow blank true
  validates :notes, length: { maximum: 1000 }, allow_blank: true

  # valide les fks
  validates :user, presence: true
  validates :relationship, presence: true

  def full_name
    "#{first_name} #{last_name}"
  end
end
