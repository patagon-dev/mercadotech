Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'add_social_providers_link_configuration_menu',
  insert_bottom: '[data-hook="admin_configurations_sidebar_menu"]',
  text: <<-HTML
                <% unless current_spree_user.vendor? %>
                  <%= configurations_sidebar_menu_item Spree.t(:social_authentication_methods), spree.admin_authentication_methods_path %>
                <% end %>
  HTML
)

Deface::Override.new(
  virtual_path: 'spree/admin/shared/sub_menu/_configuration',
  name: 'Display newsletter tab in configuration section',
  insert_after: "erb[loud]:contains('Spree.t(:stores)')",
  text: <<-HTML
                <%= configurations_sidebar_menu_item(Spree.t(:newsletter, scope: :list), admin_lists_path) if can? :manage, Spree::List %>
  HTML
)
