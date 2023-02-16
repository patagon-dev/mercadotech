Deface::Override.new(
  virtual_path: 'spree/admin/return_authorizations/index',
  name: 'Add option to generate shipping label',
  insert_bottom: 'td.actions',
  text: <<-HTML
            <% if !return_authorization.shipment_label.present? || return_authorization.pending_pickup? %>
              <%= link_to_with_icon('file', Spree.t('admin.return_authorization.label'), admin_order_generate_return_shipping_label_path(@order, return_authorization), remote: true, method: :put, no_text: true, class: 'btn btn-outline-secondary btn-sm generate-label', 'data-disable-with' => "<span class='icon icon-file'></span>") %>
            <% end %>
  HTML
)
