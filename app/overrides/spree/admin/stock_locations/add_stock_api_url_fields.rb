Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'add_enable_stock_api',
  insert_after: 'div[data-hook="stock_location_rma_default"]',
  text: <<-HTML
               <div class="checkbox my-2" data-hook="stock_location_enable_stock_api">
                 <%= label_tag :enable_stock_api do %>
                 <%= f.check_box :enable_stock_api %>
                 <%= Spree.t(:stock_api_checkbox_text) %>
                <% end %>
               </div>
  HTML
)

Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'add_stock_api_url',
  insert_after: 'div[data-hook="stock_location_state"]',
  text: <<-HTML
           <div class="form-group" data-hook="stock_location_stock_api_url">
             <%= f.label :stock_api_url, Spree.t(:stock_api_url) %>
             <%= f.text_field :stock_api_url, class: 'form-control' %>
           </div>
  HTML
)

Deface::Override.new(
  virtual_path: 'spree/admin/stock_locations/_form',
  name: 'add_notification_email_field',
  insert_after: 'div[data-hook="stock_location_stock_api_url"]',
  text: <<-HTML
           <div class="form-group" data-hook="stock_notification_email_field">
             <%= f.label :notification_email, Spree.t(:notification_email) %>
             <%= f.email_field :notification_email, class: 'form-control' %>
           </div>
  HTML
)
