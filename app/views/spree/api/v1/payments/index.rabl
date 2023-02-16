object false
child(@payments => :payments) do
  attributes *payment_attributes
  if @payments.from_webpay.present?
    node(:webpay_auth_code) { |p| p.webpay_ws_mall_params_authorization_code }
    node(:webpay_payment_quota) { |p| p.webpay_ws_mall_params_installments }
    node(:webpay_card_number) { |p| p.webpay_ws_mall_params_card_number }
    node(:webpay_payment_type) { |p| p.webpay_ws_mall_params_payment_type_code }
    node(:webpay_params) { |p| p.webpay_params }
    node(:webpy_order_number) { |p| p.webpay_ws_mall_params_buyorder }
    node(:webpay_trx_date) { |p| p.order.completed_at.to_s }
  end
end
node(:count) { @payments.count }
node(:current_page) { params[:page].try(:to_i) || 1 }
node(:pages) { @payments.total_pages }
