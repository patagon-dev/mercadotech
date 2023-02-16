namespace :destroy do
  desc 'Destroy duplicate images'
  task duplicate_images: :environment do
    images =  Spree::Image.where(viewable_type: 'Spree::Variant')
    duplicate_images = images.where.not(id: Spree::Image.group(:created_at).select("min(id)"))

    begin
     duplicate_images.each do |image|
     image.destroy!
    end
    rescue Exception => e
     puts "Exception occurs: #{e}"
    end
  end
end
