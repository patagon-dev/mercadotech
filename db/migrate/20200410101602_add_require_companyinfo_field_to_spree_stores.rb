class AddRequireCompanyinfoFieldToSpreeStores < ActiveRecord::Migration[6.0]
  def change
    add_column :spree_stores, :require_company_info_in_address, :boolean
  end
end
