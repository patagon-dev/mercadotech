namespace :products do
  desc 'add similar products for same partnumber products'
  task add_similar_products: :environment do
    puts '******** Get similar products ***********'
    similar_prods = Spree::Product.where(partnumber: Spree::Product.group('partnumber').select('partnumber').having('COUNT(partnumber) > 1').pluck(:partnumber))
    relation_type = Spree::RelationType.find_by(name: 'Similar Products')
    return false unless relation_type

    similar_prods.map do |prod|
      dup_products = similar_prods.where(partnumber: prod.partnumber).where.not(id: prod.id)
      puts "******* duplicate products for partnumber #{prod.partnumber} are: #{dup_products.count} ***********"

      require_similar_products = dup_products.where.not(id: prod.similar_products.pluck(:id))
      puts "***** Similar products to be created: #{require_similar_products.count} for partnumber #{prod.partnumber} ************"

      begin
        require_similar_products.each do |sm_product|
          prod.relations.create(relation_type_id: relation_type.id, related_to_type: prod.class.name, related_to_id: sm_product.id)
        end
      rescue Exception => e
        puts "ERROR occured while creating relations - #{e}"
      end
    end
  end
end
