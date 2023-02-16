Deface::Override.new(
  virtual_path: 'spree/admin/products/new',
  name: 'Add store ids hidden field in form',
  insert_bottom: 'div[data-hook="new_product_attrs"]',
  text: <<-HTML
                <% if current_spree_user.respond_to?(:has_spree_role?) && current_spree_user.has_spree_role?(:Vendor) %>
                  <div data-hook="new_product_store_ids" class="col-12 col-md-4 d-none">
                    <%= f.field_container :store_ids, class: ['form-group'] do %>
                      <%= f.hidden_field :store_ids, value: current_spree_vendor.import_store_ids.map(&:to_i) %>
                      <%= f.error_message_on :store_ids %>
                    <% end %>
                  </div>
                <% end %>
  HTML
)
