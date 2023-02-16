# frozen_string_literal: true

FactoryBot.define do
  factory :invoice, class: Spree::Invoice do
    number { '1234' }
    via_superfactura { false }
    order
    vendor

    factory :invoice_with_superfactura_document do
      transient do
        dummy_document { true }
      end

      after(:create) do |invoice, evaluator|
        invoice.update_column(:via_superfactura, true)
        if evaluator.dummy_document
          invoice.document.attach(io: File.open(Rails.root.join('spec/fixtures/attachments', 'invoices', '1234.pdf')), filename: '1234.pdf', content_type: 'application/pdf')
        else
          # Need to run service to generate invoice
        end
        invoice.reload
      end
    end

    factory :invoice_with_manual_upload do
      before(:create) do |invoice, _evaluator|
        invoice.tipo_dte = '33'
        invoice.document.attach(io: File.open(Rails.root.join('spec/fixtures/attachments', 'invoices', '1234.pdf')), filename: '1234.pdf', content_type: 'application/pdf')
      end
    end
  end
end
