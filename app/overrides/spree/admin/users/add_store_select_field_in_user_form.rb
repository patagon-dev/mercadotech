Deface::Override.new(
  virtual_path: 'spree/admin/users/_form',
  name: 'Add store select in user form',
  insert_bottom: 'div[data-hook="admin_user_form_roles"]',
  text: <<-HTML
          <% if current_spree_user.respond_to?(:has_spree_role?) && current_spree_user.has_spree_role?(:admin) %>
            <%= f.field_container :store_ids, class: ['form-group'] do %>
              <%= f.label :store_ids, Spree.t(plural_resource_name(Spree::Store)) %>
              <%= f.collection_select(:store_ids, Spree::Store.all, :id, :name, { include_blank: 'Select a store' }, { class: 'select2', multiple: false }) %>
            <% end %>
          <% end %>
  HTML
)
