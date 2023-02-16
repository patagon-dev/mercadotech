module WebpayOneclickMallConfig
  CONFIG = YAML.load(ERB.new(File.read(Rails.root.join('config/transbank-webpay-oneclick.yml'))).result)[Rails.env]

  DEFAULT_API_KEY                             = CONFIG['webpay_oneclick_api_key']
  DEFAULT_ONECLICK_MALL_COMMERCE_CODE         = CONFIG['webpay_oneclick_commerce_code']
  DEFAULT_INTEGRATION_TYPE                    = CONFIG['webpay_oneclick_integration_type']
end
