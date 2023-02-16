require 'csv'

namespace :create do
  desc 'Create subscription status of existing users in db'
  task subscription_status: :environment do
    store_code = Spree::Store.find_by(code: 'mercadotech')&.code
    CSV.foreach("#{Rails.root}/public/mercadotech-active.csv", headers: true).each do |row|
      row_hash = row.to_h

      ActiveSupport::Cache::RedisCacheStore.new.send(:write_entry, "#{store_code}/#{row_hash['Email']}", row_hash['Email'])
      puts 'Subscription added to db'
      rescue Exception => e
        puts "Exception occurs: #{e}"
        next
    end

    CSV.foreach("#{Rails.root}/public/mercadotech-unconfirmed.csv", headers: true).each do |row|
      row_unconfirmed = row.to_h

      ActiveSupport::Cache::RedisCacheStore.new.send(:write_entry, "#{store_code}/#{row_unconfirmed['Email']}", row_unconfirmed['Email'])
      puts 'Unconfirmed subscription added to db'
      rescue Exception => e
        puts "Exception occurs: #{e}"
        next
    end
  end
end
