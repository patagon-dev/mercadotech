Deface::Override.new(
  virtual_path: 'spree/admin/shipping_methods/_form',
  name: 'show vendor specific shipping categories',
  replace: 'div[data-hook="admin_shipping_method_form_availability_fields"]',
  text: <<-HTML
                <div data-hook="admin_shipping_method_form_availability_fields" class="col-12 col-lg-6">
                  <div class="card mb-3 categories">
                    <div class="card-header">
                      <h1 class="card-title mb-0 h5">
                        <%= Spree.t(:shipping_categories) %>
                      </h1>
                    </div>

                    <div class="card-body">
                      <%= f.field_container :categories, class: ['form-group'] do %>
                        <% Spree::ShippingCategory.accessible_by(current_ability).each do |category| %>
                          <div class="checkbox">
                            <%= label_tag do %>
                              <%= check_box_tag('shipping_method[shipping_categories][]', category.id, @shipping_method.shipping_categories.include?(category)) %>
                              <%= category.name %>
                            <% end %>
                          </div>
                        <% end %>
                        <%= f.error_message_on :shipping_category_id %>
                      <% end %>
                    </div>
                  </div>
                </div>
  HTML
)
