class AddVendorReferenceInSpreePayments < ActiveRecord::Migration[6.0]
  def change
    add_reference :spree_payments, :vendor, index: true
  end
end
