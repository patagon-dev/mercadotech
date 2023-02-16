module ApplicationHelper
  include Spree::TrackersHelper

  # CSS Lookup
  def assets_lookup(_path)
    file_path = File.expand_path('.', "vendor/assets/stylesheets/spree/stores/#{current_store.code}.css")
    File.exist?(file_path) ? "spree/stores/#{current_store.code}" : "spree/stores/#{Spree::Store.default.code}"
  end

  def store_logo_lookup
    file_path = File.expand_path('.', "app/assets/images/logo/#{current_store.code}.png")
    File.exist?(file_path) ? "logo/#{current_store.code}.png" : 'logo/default_logo.png'
  end

  def store_logo(options = {})
    path = spree.respond_to?(:root_path) ? spree.root_path : main_app.root_path

    link_to path, 'aria-label': current_store.name, method: options[:method] do
      image_tag store_logo_lookup, alt: current_store.name, title: current_store.name
    end
  end

  # For s3 persisted attachment URL
  def s3_persisted_url(attachment, variant = false)
    blob = if variant
             begin
               attachment.processed
             rescue StandardError
               attachment.blob
             end
           else
             attachment.blob
           end
    url = URI(blob.url)
    "#{url.scheme}://#{url.host}/#{blob.key}"
  end
end
