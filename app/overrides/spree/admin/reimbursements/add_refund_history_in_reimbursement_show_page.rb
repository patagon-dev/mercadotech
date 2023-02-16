Deface::Override.new(
  virtual_path: 'spree/admin/reimbursements/show',
  name: 'Add refund history in show page',
  insert_after: 'fieldset.no-border-bottom',
  text: '<%= render partial: "spree/admin/shared/refund_history", locals: { refund_history: @refund_history } %>'
)
