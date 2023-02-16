require 'open-uri'

class GenerateImageVariantsJob < ApplicationJob
  queue_as :image_processing

  include ImportUtilBase
  ERROR_LOG_FILE = "public/GenerateImageVariantsErrorLog-#{Time.current}__.json".freeze


  def perform(images)
    @import_errors = {}

    styles = [
              :plp_and_carousel,
              :plp_and_carousel_xs,
              :plp_and_carousel_sm,
              :plp_and_carousel_md,
              :plp_and_carousel_lg,
              :plp
            ]

    images.each do |image|
      styles.each do |style|
        begin
          image.url(style).processed
          Rails.logger.error "Processed!"
        rescue Exception => e
          Rails.logger.error "ERROR: Image with id - #{image.id} and variant #{style}"
          data = { image_id: image.id, image_variant: style, message: e.message }
          log_data(:image_not_found, data)
        end
      end
    end
    write_log_file
  end
end
