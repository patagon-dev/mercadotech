Deface::Override.new(
  virtual_path: 'spree/admin/pages/_form',
  name: 'Add footer column select field in pages form',
  insert_after: "erb[loud]:contains('f.number_field :position')",
  text: <<-HTML
        <div class="<%= @page.show_in_footer ? 'form-group' : 'form-group d-none' %> mt-3" id="footer-column-select">
          <%= f.label :footer_column_name %>
          <%= f.select(:footer_title, Spree::Page.footer_titles.keys.map { |e| [e.titleize, e] }, {}, { :class => 'select2' }) %>
        </div>
  HTML
)
