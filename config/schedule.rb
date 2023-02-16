# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
every 1.day, at: '1:00 am' do
  runner "ImportProductsJob.new.perform('from_csv')"
end

every 1.day, at: '5:00 am' do
  rake '-s sitemap:refresh'
end

every 1.day, at: '2:00 am' do
  runner "ImportProductsJob.new.perform('from_full_scraping_hub')"
end

every 1.day, at: '8:00 am' do
  runner "ImportProductsJob.new.perform('from_quick_scraping_hub')"
end

every 1.day, at: '3:00 am' do
  runner 'Enviame::GetCarriers.new.run'
end

every 1.day, at: '3:30 am' do
  rake 'products:add_similar_products'
end

every 1.day at: '4:00 am' do
  rake 'destroy:duplicate_images'
end
# Learn more: http://github.com/javan/whenever
