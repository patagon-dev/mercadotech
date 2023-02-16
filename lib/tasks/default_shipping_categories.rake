namespace :create do
  desc 'Creating default shipping categories for existing vendors'
  task default_shipping_categories: :environment do
    vendors= Spree::Vendor.all
    default_categories = ['small', 'medium', 'large', 'extra_large']
    begin
      vendors.each do |vendor|
        default_categories.each do |default|
          Spree::ShippingCategory.find_by(name: "#{vendor.id}_#{default}", vendor_id: vendor.id) || Spree::ShippingCategory.create!(name: default, vendor_id: vendor.id)
        end
      end
    rescue Exception => e
      puts "Exception occurs: #{e}"
    end
  end
end