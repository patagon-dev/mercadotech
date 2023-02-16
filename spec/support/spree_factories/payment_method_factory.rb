FactoryBot.define do
  factory :webpay_payment_method, class: Spree::Gateway::WebpayWsMall do
    name { 'Webpay' }
  end

  factory :webpay_oneclick_payment_method, class: Spree::Gateway::WebpayOneclickMall do
    name { 'Webpay Oneclick' }
  end
end
