module ApplicationHelper
  def asset_exists?(filename)
    if Rails.configuration.assets.compile
      # En mode développement
      Rails.application.assets.find_asset(filename).present?
    else
      # En production (assets précompilés)
      Rails.application.assets_manifest.find_sources(filename).present?
    end
  end
end
