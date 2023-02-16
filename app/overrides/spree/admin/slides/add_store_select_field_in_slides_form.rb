Deface::Override.new(
  virtual_path: 'spree/admin/slides/_form',
  name: 'Add store select in slides form',
  insert_bottom: '.row',
  text: <<-HTML
        <div class="col-md-6">
          <% if current_spree_user.respond_to?(:has_spree_role?) && current_spree_user.has_spree_role?(:admin) %>
            <%= f.field_container :store_id, class: ['form-group'] do %>
              <%= f.label :store_id, Spree.t(plural_resource_name(Spree::Store)) %>
              <%= f.collection_select(:store_id, Spree::Store.all, :id, :name, { include_blank: 'Select a store' }, { class: 'select2', multiple: false }) %>
            <% end %>
          <% end %>
        </div>
  HTML
)
