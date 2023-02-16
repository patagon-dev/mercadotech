class AddRecurringFrequencyFieldsToSpreeVendors < ActiveRecord::Migration[6.1]
  def change
    add_column :spree_vendors, :quick_recurring_frequency, :string
    add_column :spree_vendors, :full_recurring_frequency, :string
  end
end
