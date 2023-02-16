require 'open-uri'

class UploadDatasheetFilesJob < ApplicationJob
  queue_as :import

  def perform(datasheet_files)
    products = Spree::Product.where(id: datasheet_files.stringify_keys.keys)
    products.each do |product|
      persisted_pdf_ids = product.datasheet_files.attachments.pluck(:id)
      @new_pdf_created = []

      datasheet_files["#{product.id}".to_sym].each do |datasheet_name, source_url|
        save_datasheet(datasheet_name, source_url, product)
      end

      begin
        ActiveStorage::Attachment.where(id: persisted_pdf_ids).destroy_all if @new_pdf_created.include?(true) && persisted_pdf_ids.present?
      rescue Exception => e
        Rails.logger.error "ERROR OLDDATASHEETDESTROY product IDS: #{product.id} with datasheet-attachment-ids - #{persisted_pdf_ids}. Message: #{e}"
      end
    end
  end

  def save_datasheet(datasheet_name, source_url, product)
    checksums = product.datasheet_files.attachments.map { |att| att.blob.checksum }

    ActiveRecord::Base.transaction do
      begin
        url = source_url.gsub(/\s+/, "%20")
        filename = url.split('/').last
        filename = filename.prepend("#{datasheet_name}_")
        tempfile = URI.open(url.strip)
        checksum = Digest::MD5.base64digest(tempfile.read)
        existing_checksum = checksums.include?(checksum)

        if !existing_checksum.present?
          @new_pdf_created << product.datasheet_files.attach(io: File.open(tempfile.path), filename: filename, content_type: tempfile.content_type)
          checksums.push(checksum)
        end
      rescue Exception => e
        Rails.logger.error "DATASHEET ERROR: Product with ID: - #{product.id} and datasheet #{datasheet_name}, URL: #{source_url}. Message: #{e}"
      end
    end
  end
end
