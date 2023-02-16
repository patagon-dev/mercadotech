Deface::Override.new(
    virtual_path: 'spree/admin/reimbursements/edit',
    name: 'Add check on reimbursement button',
    replace: 'div[data-hook="reimburse-buttons"]',
    text:    <<-HTML
                  <div class="form-actions" data-hook="reimburse-buttons">
                    <% if !@reimbursement.reimbursed? %>
                      <% if @reimbursement_objects.any? %>
                        <%= button_to [:perform, :admin, @order, @reimbursement], { class: 'btn btn-primary', method: 'post' } do %>
                          <span class="icon icon-save"></span>
                          <%= Spree.t(:reimburse) %>
                        <% end %>
                        <span class="or"><%= Spree.t(:or) %></span>
                      <% end %>
                      <%= button_link_to Spree.t('actions.cancel'), url_for([:edit, :admin, @order, @reimbursement.customer_return]), icon: 'remove-sign' %>
                    <% end %>
                  </div>
                HTML
)

Deface::Override.new(
    virtual_path: 'spree/admin/reimbursements/edit',
    name: 'fixing css error comming in clear the selected option',
    insert_after: "erb[loud]:contains('Spree.t(:new_stock_movement)')",
    replace: "erb[loud]:contains('item_fields.collection_select')",
    text:    <<-HTML
              <%= item_fields.collection_select :exchange_variant_id, return_item.eligible_exchange_variants, :id, :exchange_name, { include_blank: true }, { class: "select2-clear return-item-exchange-selection", "data-placeholder" => Spree.t(:select_replace_by) } %>
                HTML
)
