namespace :update do
  desc 'Update existing RA and Customer return for vendor'
  task rma: :environment do
    Spree::ReturnAuthorization.all.each do |return_authorization|
      vendor_ids = return_authorization.return_items.map { |rt| rt.inventory_unit&.variant&.vendor_id }
      puts "Return Authorization - #{return_authorization.id}, vendor_ids - #{vendor_ids}"
      return_authorization.update_column(:vendor_id, vendor_ids.uniq[0])
      puts 'Updated!'
    end

    puts '==========================================================================='

    Spree::CustomerReturn.all.each do |customer_return|
      vendor_ids = customer_return.return_items.map { |rt| rt.inventory_unit&.variant&.vendor_id }
      puts "Customer Return - #{customer_return.id}, vendor_ids - #{vendor_ids}"
      customer_return.update_column(:vendor_id, vendor_ids.uniq[0])
      puts 'Updated!'
    end
  end
end
