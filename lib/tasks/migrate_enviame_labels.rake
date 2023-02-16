namespace :enviame_label do
  desc 'Add Enviame shipping label in Shipment labels'
  task migrate: :environment do
    Spree::Shipment.all.each do |shipment|
      next unless shipment.url_label?

      begin
        puts "Migrating Shipment: #{shipment.number}, ORDER: #{shipment.order&.number}"
        puts "Saving Shipment #{shipment.number} and label url: #{shipment.url_label}"

        label = shipment.shipment_labels.build
        label.assign_attributes({
                                  tracking_number: shipment.tracking,
                                  label_url: shipment.url_label
                                })
        label.save!

        attachment = ActiveStorage::Attachment.where(record_id: shipment.id, name: 'enviame_label').take

        label.enviame_label.attach(attachment.blob) if attachment.present?

        puts "Migrated data for: #{shipment.number}"
      rescue Exception => e
        puts "Data not Migrated for: #{shipment.number} and label url is #{shipment.url_label}"
        puts "Got ERROR: #{e.message}"
        next
      end
    end
  end
end
