module WebpayMallNormalConfig
  CONFIG = YAML.load(ERB.new(File.read(Rails.root.join('config/transbank-webpay-mall-normal.yml'))).result)[Rails.env]

  DEFAULT_API_KEY                        = CONFIG['webpay_normal_api_key']
  DEFAULT_COMMERCE_CODE                  = CONFIG['webpay_normal_commerce_code']
  DEFAULT_INTEGRATION_TYPE               = CONFIG['webpay_normal_integration_type']
end
