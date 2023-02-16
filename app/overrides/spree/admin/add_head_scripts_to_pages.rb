Deface::Override.new(
  virtual_path: 'spree/admin/pages/_form',
  name: 'Add head scripts to pages',
  insert_after: 'div[data-hook="admin_page_form_left"] > .form-group:nth-last-child(2)',
  text: <<-HTML
                <div class="form-group">
                  <%= f.label :head_scripts, 'Header Scripts' %>
                  <%= f.text_area :head_scripts, rows: 3, class: 'form-control' %>
                  <%= f.error_message_on :head_scripts %>
                </div>
  HTML
)
