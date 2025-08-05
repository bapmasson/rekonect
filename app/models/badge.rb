class Badge < ApplicationRecord
  has_many :user_badges
  has_many :users, through: :user_badges
  has_one_attached :image

  # titre est obligatoire, unique, max 20 caractères ( succès)
  validates :title, presence: true, uniqueness: true, length: { maximum: 50 }

  # description obligatoire pour motiver l'user
  validates :description, presence: true, length: { maximum: 500 }

  # condition d'obtention du badge obligatoire, max 500 caractères
  validates :condition_description, presence: true, length: { maximum: 500 }
end
