Deface::Override.new(
  virtual_path: 'spree/admin/products/_form',
  name: 'override sku field in product edit form',
  replace: 'div[data-hook="admin_product_form_sku"]',
  text:       <<-HTML
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
  name: 'add checkbox for skip full or quick import scripts',
  insert_top: 'div[data-hook="admin_product_form_right"]',
  text:       <<-HTML
                <div class="my-3">
                  <%= f.field_container :skip_full_import do %>
                    <%= f.check_box :skip_full_import %>
                    <%= f.label :skip_full_import, Spree.t(:skip_full_import), class: 'form-check-label' %>
                  <% end %>
                  <%= f.field_container :skip_quick_import do %>
                    <%= f.check_box :skip_quick_import %>
                    <%= f.label :skip_quick_import, Spree.t(:skip_quick_import), class: 'form-check-label' %>
                  <% end %>
                </div>
              HTML
)
