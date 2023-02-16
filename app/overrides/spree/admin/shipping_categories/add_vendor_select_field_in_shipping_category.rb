Deface::Override.new(
  virtual_path: 'spree/admin/shipping_categories/_form',
  name: 'Add vendor field in shipping category form',
  insert_bottom: 'div[data-hook="admin_shipping_category_form_fields"]',
  text: <<-HTML
              <% if current_spree_user.respond_to?(:has_spree_role?) && current_spree_user.has_spree_role?(:Vendor) %>
                <div data-hook="vendor_id" class="form-group">
                  <%= f.field_container :vendor_id, class: ['form-group'] do %>
                    <%= f.hidden_field :vendor_id, value: current_spree_vendor.id %>
                    <%= f.error_message_on :vendor_id %>
                  <% end %>
                </div>
              <% else %>
                <div data-hook="vendor" class="form-group">
                  <%= f.field_container :vendor, class: ['form-group'] do %>
                    <%= f.label :vendor_id, Spree.t(:vendor) %>
                    <%= f.collection_select(:vendor_id, Spree::Vendor.active, :id, :name, { include_blank: Spree.t('match_choices.none') }, { class: 'select2' }) %>
                    <%= f.error_message_on :vendor %>
                  <% end %>
                </div>
              <% end %>
  HTML
)
