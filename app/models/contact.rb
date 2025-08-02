class Contact < ApplicationRecord
  belongs_to :user
  belongs_to :relationship
  belongs_to :contact_user, class_name: "User", optional: true
  has_many :messages
  has_one_attached :photo

  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :notes, length: { maximum: 1000 }, allow_blank: true
  validates :user, presence: true
  validates :relationship, presence: true
  validates :photo_name,
            format: { with: /\A[a-zA-Z0-9_\-\.]+\z/, allow_blank: true,
                      message: "ne doit pas contenir d'espaces ou caractères spéciaux" }

  include Rails.application.routes.url_helpers

  def photo_path
    if photo.attached?
      rails_blob_url(photo, only_path: true)
    elsif photo_name.present?
      ActionController::Base.helpers.asset_path(photo_name)
    else
      ActionController::Base.helpers.asset_path('default-avatar.png')
    end
  end

  def photo_variant(size = [64, 64])
    photo.variant(resize_to_fill: size) if photo.attached?
  end

  def full_name
    "#{first_name} #{last_name}"
  end
end
