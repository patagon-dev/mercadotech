namespace :destroy do
  desc 'Destroy decathlon product variants'
  task vendor_product_variants: :environment do
    vendor = Spree::Vendor.find_by(full_spider: 'decathlon')
    return unless vendor.present?

    vendor.products.each do |product|
      product.variants.destroy_all
      puts "#{product.name} variants destroyed successfully"

      rescue Exception => e
        puts "Exception occurs: #{e}"
        next
    end
  end
end
