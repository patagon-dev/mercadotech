class ImportProductsJob < ApplicationJob
  queue_as :import

  def perform(method_name)
    Spree::Vendor.active.all.each do |vendor|
      conditional_constrain = method_name == 'from_csv' ? vendor.products_csv_url : vendor.scrapinghub?
      next unless conditional_constrain
      quick_frequency = vendor.quick_recurring_frequency.present? ? vendor.quick_recurring_frequency : '0 */1 * * * America/Santiago'
      full_frequency = vendor.full_recurring_frequency.present? ? vendor.full_recurring_frequency : '0 */24 * * * America/Santiago'

      cron_frequency = method_name == 'from_quick_scraping_hub' ? quick_frequency : full_frequency
      job = Sidekiq::Cron::Job.new(name: "Import Product job for #{vendor.name} #{method_name}", cron: cron_frequency, class: 'ImportVendorProducts', args: [vendor.id, method_name], queue: :import)

      unless job.save
        puts job.errors # will return array of errors
      end
    end
  end
end
