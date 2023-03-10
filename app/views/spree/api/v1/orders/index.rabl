object false
child(@orders.uniq => :orders) do
  extends 'spree/api/v1/orders/order'
end
node(:count) { @orders.uniq.count }
node(:current_page) { params[:page].try(:to_i) || 1 }
node(:pages) { @orders.total_pages }
