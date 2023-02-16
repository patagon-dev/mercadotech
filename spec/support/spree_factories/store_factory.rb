# frozen_string_literal: true

FactoryBot.modify do
  factory :store, class: Spree::Store do
    invoice_types ['33'] # specific type of invoice type
    after(:create) do |store|
      store.mailer_logo.attach(io: File.open(Rails.root.join('spec/fixtures/attachments', 'logo', 'test_email_logo.png')), filename: 'test_email_logo.png', content_type: 'image/png')
    end
  end
end
