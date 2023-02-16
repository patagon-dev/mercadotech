Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'Add skip from import to stock locations form',
  insert_bottom: 'div[data-hook="stock_location_status"]',
  text: <<-HTML
                <div class="checkbox my-2" data-hook="stock_location_skip_import">
                  <%= label_tag :skip_from_import do %>
                    <%= f.check_box :skip_from_import %>
                    <%= Spree.t(:skip_from_import) %>
                  <% end %>
                </div>
  HTML
)
