class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable

  has_one_attached :avatar

  has_many :contacts
  has_many :user_badges
  has_many :badges, through: :user_badges
  has_many :sent_messages, class_name: "Message", foreign_key: :sender_id
  has_many :received_messages, class_name: "Message", foreign_key: :receiver_id

  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :validatable

  # Validation du nom et prénom de l'utilisateur
  validates :first_name, :last_name, presence: true, length: { minimum: 2, maximum: 50 }
  # Validation de l'adresse de l'utilisateur
  validates :address, presence: true, length: { minimum: 10, maximum: 200 }
  # Validation de la date de naissance de l'utilisateur
  validates :birth_date, presence: true
  # Valide que l'utilisateur ait au moins 10 ans en appelant la méthode privée minimum_age
  validate :minimum_age
  # Validation du pseudo unique de l'utilisateur + message si ce n'est pas le cas
  validates :username, presence: true, uniqueness: { message: "ce pseudo est déjà pris" }, length: { minimum: 3, maximum: 20 }
  # Validation du numéro de téléphone de l'utilisateur
  validates :phone_number, presence: true, length: { minimum: 7, maximum: 15 }, format: { with: /\A\+?\d{7,15}\z/, message: "doit être un numéro de téléphone valide" }

  # ajout de l'xp level, gamification non négatif

  validates :xp_level, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  def level
    (xp_points / 100) + 1
  end

  def xp_for_next_level
    100
  end

  def xp_progress
    xp_points % 100
  end

  def xp_percent
    (xp_progress.to_f / xp_for_next_level * 100).round
  end

  def xp_points
    self[:xp_points] || 0
  end

  private

  # Valide que l'utilisateur a au moins 10 ans
  def minimum_age
    if birth_date.present? && birth_date > 10.years.ago.to_date
      errors.add(:birth_date, "doit correspondre à un utilisateur d'au moins 10 ans")
    end
  end

    # Exemple de mise à jour d'un contact avec un nom de photo
  def photo_path
    # Renvoie le chemin de l'image dans app/assets/images, ou l'avatar par défaut
    if photo_name.present?
      Rails.application.assets.find_asset(photo_name).try(:pathname).to_s
    else
      Rails.application.assets.find_asset('default-avatar.png').try(:pathname).to_s
    end
  end
end
