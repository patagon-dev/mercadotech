require 'open-uri'

class UploadVariantImagesJob < ApplicationJob
  queue_as :import

  def perform(variant_images)
    @generated_images = []

    variant_images.keys.each do |variant_id|
      save_images(variant_id, variant_images[variant_id])
    end

    GenerateImageVariantsJob.perform_later(@generated_images.uniq) if @generated_images.any?
  end

  def save_images(variant_id, images)
    images = images.reject { |e| e.to_s.empty? || URI.parse(e.to_s.gsub(/\s+/, "%20")).host.nil? }

    @persisted_image_ids = Spree::Image.where(viewable_id: variant_id, viewable_type: 'Spree::Variant').pluck(:id)
    asset_ids = Spree::Asset.where(viewable_id: variant_id, viewable_type: 'Spree::Variant').pluck(:id)
    blob_ids = ActiveStorage::Attachment.where(record_id: asset_ids).pluck(:blob_id)
    checksums = ActiveStorage::Blob.where(id: blob_ids).pluck(:checksum)

    @existing_images_checksums = []
    @new_images = []
    images.each do |image|
      ActiveRecord::Base.transaction do
        begin
          image = image.gsub(/\s+/, "%20")
          filename = image.split('/').last
          filename = filename.split('?')[0] if filename.include?('?')
          tempfile = URI.open(image.strip)
          checksum = Digest::MD5.base64digest(tempfile.read)
          existing_img = checksums.include?(checksum)
          @existing_images_checksums << checksum if existing_img.present?

          unless existing_img.present?
            @new_images << Spree::Image.create!(viewable_type: 'Spree::Variant', viewable_id: variant_id,
                                                      attachment: { io: File.open(tempfile.path), filename: filename, content_type: tempfile.content_type })
            @generated_images += @new_images
            checksums.push(checksum)
          end
        rescue Exception => e
          Rails.logger.error "Exception occured for #{image.strip} and variant - #{variant_id} in image upload. Message: #{e}"
          next
        end
      end
    end
    destroy_existing_images
  end

  def destroy_existing_images
    begin
      if @persisted_image_ids.present? && @existing_images_checksums.present?
        existing_images_ids = Spree::Image.where(id: @persisted_image_ids).select do |img|
          @existing_images_checksums.include?(img.attachment.blob.checksum)
        end.pluck(:id)
        image_ids = @persisted_image_ids - existing_images_ids
        Spree::Image.where(id: image_ids).destroy_all if image_ids.present?
      end

      Spree::Image.where(id: @persisted_image_ids).destroy_all if @persisted_image_ids.present? && !@existing_images_checksums.present? && @new_images.present?
    rescue Exception => e
      Rails.logger.error "ERROR OLDIMAGESDESTROY occured images ids: #{@persisted_image_ids}. Message: #{e}"
    end
  end
end
