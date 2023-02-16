class AddFieldsToSpreeReturnAuthorization < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_return_authorizations, :request_pickup, :boolean, default: false
    add_column :spree_return_authorizations, :pickup_date, :date
    add_column :spree_return_authorizations, :range_time, :integer, default: 0
  end
end
