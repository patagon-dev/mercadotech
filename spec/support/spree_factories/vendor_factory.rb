# frozen_string_literal: true

FactoryBot.define do
  factory :vendor, class: Spree::Vendor do
    name { 'Petacl SpA' }
    about_us { 'About us...' }
    contact_us { 'Contact us...' }
    state { 'active' }
    enviame_vendor_id { 620 }
    rut { '76.124.329-2' }

    factory :vendor_with_scrapinghub do
      after(:create) do |vendor, _evaluator|
        vendor.update_columns(
          import_options: 'scrapinghub',
          scrapinghub_api_key: 'scrapinghub-api-key',
          scrapinghub_project_id: '123456',
          full_spider: 'spidername',
          quick_spider: 'spidername2'
        )
        vendor.reload
      end
    end

    factory :vendor_with_superfactura do
      after(:create) do |vendor, _evaluator|
        vendor.update_columns(
          invoice_options: 'superfactura_api',
          superfactura_login: 'email@example.com',
          superfactura_password: 'password',
          superfactura_environment: 'cer'
        )
        vendor.reload
      end
    end

    factory :vendor_with_bank_transfer do
      after(:create) do |vendor, _evaluator|
        vendor.update_columns(
          enable_bank_transfer: true,
          bank_transfer_url: 'https://api.mercadoempresas.cl/devolucion_santander/',
          bank_transfer_login: 'devo',
          bank_transfer_password: 'password'
        )
        vendor.reload
      end
    end

    factory :vendor_with_moova do
      after(:create) do |vendor, _evaluator|
        vendor.update_columns(
          enable_moova: true,
          moova_api_key: 'moova-api-key',
          moova_api_secret: 'moova-api-secret'
        )
        vendor.reload
      end
    end
  end
end
