class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :relationship
  belongs_to :contact_user, class_name: "User", optional: true
  has_many :messages
  has_one_attached :photo

  # nom obligatoire
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }

  # notes, max 1000 caractère, autorise le champ vide avec allow blank true
  validates :notes, length: { maximum: 1000 }, allow_blank: true

  # valide les fks
  validates :user, presence: true
  validates :relationship, presence: true

  def photo_path
    # Renvoie le chemin de l'image dans app/assets/images, ou l'avatar par défaut
    if photo_name.present?
      Rails.application.assets.find_asset(photo_name).try(:pathname).to_s
    else
      Rails.application.assets.find_asset('default-avatar.png').try(:pathname).to_s
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
