Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'add_rma_default',
  insert_after: 'div[data-hook="stock_location_propagate_all_variants"]',
  text: <<-HTML
                <div class="checkbox my-2" data-hook="stock_location_rma_default">
                  <%= label_tag :rma_default do %>
                    <%= f.check_box :rma_default %>
                    <%= Spree.t(:rma_default) %>
                  <% end %>
                </div>
  HTML
)
