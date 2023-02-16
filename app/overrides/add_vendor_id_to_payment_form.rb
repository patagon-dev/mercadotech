Deface::Override.new(
  virtual_path: 'spree/admin/payments/_form',
  name: 'Add hidden vendor id to payments form',
  insert_bottom: 'div[data-hook="admin_payment_form_fields"]',
  text: <<-HTML
                <% if current_spree_user.respond_to?(:has_spree_role?) && current_spree_user.has_spree_role?(:admin) %>
                  <div class="form-group">
                    <%= f.label :vendor_id, Spree.t(:vendor) %>
                    <%= f.select :vendor_id, Spree::Vendor.active.pluck(:name, :id), {}, { class: "select2 js-filterable" } %>
                  </div>
                <% end %>
                <% if defined?(current_spree_vendor) && current_spree_vendor %>
                  <div class="form-group">
                    <%= f.hidden_field :vendor_id, value: current_spree_vendor.id, class: 'form-control' %>
                  </div>
                <% end %>
  HTML
)
