Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: 'override sku field in product edit form',
  replace: 'div[data-hook="admin_product_form_sku"]',
  text: <<-HTML
                <div data-hook="admin_product_form_sku">
                  <%= f.field_container :master_sku, class: ['form-group'] do %>
                    <%= f.label :master_sku, Spree.t(:master_sku) %>
                    <%= f.text_field :sku, size: 16, value: @product.sku.split('_', 2)[1], class: 'form-control' %>
                  <% end %>
                </div>
  HTML
)

Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: 'override shipping category field in product edit form',
  replace: 'div[data-hook="admin_product_form_shipping_categories"]',
  text: <<-HTML
              <div data-hook="admin_product_form_shipping_categories">
                <%= f.field_container :shipping_category, class: ['form-group'] do %>
                  <%= f.label :shipping_category_id, Spree.t(:shipping_category) %>
                  <%= f.collection_select(:shipping_category_id, @shipping_categories, :id, :name_without_prefix, { include_blank: Spree.t('match_choices.none') }, { class: 'select2' }) %>
                  <%= f.error_message_on :shipping_category %>
                <% end %>
              </div>
  HTML
)
