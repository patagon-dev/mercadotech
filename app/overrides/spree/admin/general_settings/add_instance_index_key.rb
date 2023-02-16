Deface::Override.new(
  virtual_path: 'spree/admin/general_settings/edit',
  name: 'Add instance index key',
  insert_after: 'div[data-hook="general_settings_cache"]',
  text: <<-HTML
	          <%#-------------------------------------------------%>
	          <%# Set instance index key                          %>
	          <%#-------------------------------------------------%>

	          <div class="card mb-3">
	            <div class="card-header">
	              <h1 class="card-title mb-0 h5">
	                <%= Spree.t(:title, scope: :instance_index_key) %>
	              </h1>
	            </div>

	            <div class="card-body">
	              <div class="form-group">
	                <%= label_tag :instance_index_key, Spree.t(:label, scope: :instance_index_key) %>
	                <%= select_tag :instance_index_key, options_for_select([0, 1, 2, 3, 4, 5], selected: Spree::Config[:instance_index_key] ), class: 'form-control' %>
	              </div>
	            </div>
	          </div>
        HTML
)
