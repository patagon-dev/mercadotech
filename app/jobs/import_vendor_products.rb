class ImportVendorProducts < ApplicationJob
  queue_as :import

  def perform(vendor_id, method_name)
    unless vendor_id.present?
      puts "Vendor id not found"
      return
    end

    product_import = Products::Import.new(vendor_id)
    product_import.send(method_name.to_s)
  end
end
