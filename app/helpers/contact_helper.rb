module ContactHelper
  def contact_image_path(contact)
    if contact.photo.attached?
      # Image uploadée avec ActiveStorage
      url_for(contact.photo.variant(resize_to_fill: [60, 60]))
    elsif contact.photo_name.present? && asset_exists?(contact.photo_name)
      # Image dans assets/images
      asset_path(contact.photo_name)
    else
      # Image par défaut
      asset_path("default-avatar.png")
    end
  end

  private

  def asset_exists?(filename)
    Rails.application.assets.find_asset(filename).present? rescue false
  end
end
