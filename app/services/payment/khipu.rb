require 'net/http'

class Payment::Khipu
  HOST = 'https://khipu.com/api/2.0'.freeze
  attr_reader :payment

  def initialize(number)
    @payment = Spree::Payment.find_by_number(number)
  end

  def payment_refund
    header_params = {
      'Content-Type' => 'application/x-www-form-urlencoded',
      'Accept' => 'application/json'
    }
    header_params['Authorization'] = update_params_for_auth!(header_params)

    url = URI(HOST + payment_path(payment.khipu_trx_id))
    https = Net::HTTP.new(url.host, url.port)
    https.use_ssl = true

    request = Net::HTTP::Post.new(url)

    header_params.each do |key, value|
      request[key] = value
    end
    response = https.request(request)
    response.code == '200'
  rescue StandardError
    false
  end

  private

  def update_params_for_auth!(params)
    http_method = :post
    query_params = {}
    form_params = {}
    body = nil
    params = query_params.merge(form_params)

    encoded = {}
    params.each do |k, v|
      encoded[percent_encode(k)] = percent_encode(v)
    end
    to_sign = http_method.to_s.upcase + '&' + percent_encode(HOST + payment_path(payment.khipu_trx_id))

    encoded.keys.sort.each do |key|
      to_sign += "&#{key}=" + encoded[key]
    end
    to_sign += '&' + body if !body.nil? && params['Content-Type'] == 'application/json'
    hash = OpenSSL::HMAC.hexdigest(OpenSSL::Digest.new('sha256'), payment.vendor.khipu_secret, to_sign)
    payment.vendor.khipu_id + ':' + hash
  end

  def payment_path(id)
    "/payments/#{id}/refunds"
  end

  def percent_encode(v)
    URI.escape(v.to_s.to_str, /[^a-zA-Z0-9\-._~]/)
  end
end
