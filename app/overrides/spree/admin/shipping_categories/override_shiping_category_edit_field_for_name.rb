Deface::Override.new(
  virtual_path: 'spree/admin/shipping_categories/_form',
  name: 'override shipping category edit form for name field',
  replace: 'div[data-hook="name"]',
  text: <<-HTML
                <div data-hook="name" class="form-group">
                  <%= f.field_container :name, class: ["form-group"] do %>
                    <%= f.label :name, Spree.t(:name) %><br>
                      <%= f.text_field :name, value: params[:action] == "edit" ? @shipping_category.name[2..-1] : nil, class: 'form-control' %>
                    <%= f.error_message_on :name %>
                  <% end %>
                </div>
  HTML
)
