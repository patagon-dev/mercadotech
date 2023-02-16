namespace :update do
  desc 'Sanitize exsisting products description'
  task sanitize_products_description: :environment do
    products = Spree::Product.where("description IS NOT NULL AND description !=''")

    puts "Total number of product:  #{products.count}"

    products.each do |product|
      next if Spree::Config[:show_raw_product_description]

      puts "Product Name:  #{product.name}"
      description = product.description.to_s.gsub(/(.*?)\r?\n\r?\n/m, '<p>\1</p>')
      product.update_column(:description, description)
      puts 'Product Updated!'

    rescue Exception => e
      puts "Exception occurs: #{e}, Product id: #{product.id}"
      next
    end
    puts 'Updated !'
  end
end
