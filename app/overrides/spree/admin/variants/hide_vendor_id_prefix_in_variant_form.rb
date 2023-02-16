Deface::Override.new(
  virtual_path: 'spree/admin/variants/_form',
  name: 'override sku field in variants form',
  replace: 'div[data-hook="sku"]',
  text: <<-HTML
                <div class="form-group" data-hook="sku">
                  <%= f.label :sku, Spree.t(:sku) %>
                  <%= f.text_field :sku, value: @variant.sku.split('_', 2)[1], class: 'form-control' %>
                </div>
  HTML
)

Deface::Override.new(
  virtual_path: 'spree/admin/variants/_form',
  name: 'add name field in variants form',
  insert_before: 'div[data-hook="sku"]',
  text: <<-HTML
                <div class="form-group" data-hook="name">
                  <%= f.label :name, Spree.t(:name) %>
                  <%= f.text_field :name, class: 'form-control' %>
                </div>
  HTML
)
