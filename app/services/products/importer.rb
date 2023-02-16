require 'csv'

class Products::Importer < Products::Base
  attr_reader :vendor_products

  ERROR_LOG_FILE = "ProductCSVImportLog-#{Time.current}__.json".freeze

  def process_import
    CSV.foreach(path, headers: true) do |row|
      row_hash = row.to_h
      all_required_field_present = row_hash.values_at('sku', 'partnumber', 'price', 'stock').all?
      next unless all_required_field_present

      if row_hash['sku'].present?
        formatted_sku = row_hash['sku']
        begin
          ::ActiveRecord::Base.transaction do
            # vendor id prefix with sku
            formatted_sku = "#{vendor_id}_#{row_hash['sku']}"
            variant = Spree::Variant.where(sku: formatted_sku, is_master: true).first

            if variant
              attributes = product_attributes(row_hash)
              product = variant.product

              Searchkick.callbacks(false) do # temporarily skip updates
                product.update!(attributes)
              end

              variant.volume_prices.destroy_all

              # save stock for stock locations
              if row_hash['stock'].present?
                stocks = row_hash['stock'].tr(" ,\;\n", ',').split(',')
                save_variant_stock(variant, stocks)
              end

              if row_hash['volume_price'].present?
                volume_prices = row_hash['volume_price'].tr(" ,\;\n", ',').split(',')
                save_volume_price(variant, volume_prices)
              end

              @product_ids.push(product.id)
            else
              raise VariantNotFoundError
            end
          end
        rescue VariantNotFoundError => e
          data = { partnumber: row_hash['partnumber'], sku: formatted_sku, message: e.message }
          log_data(:variant_not_found, data)
        rescue ActiveRecord::RecordInvalid => e
          data = { partnumber: row_hash['partnumber'], sku: formatted_sku, message: e.message }
          log_data(:record_invalid, data)
        rescue Exception => e
          data = { partnumber: row_hash['partnumber'], sku: formatted_sku, message: e.message }
          log_data(:general, data)
        end
      else
        data = { partnumber: row_hash['partnumber'], sku: formatted_sku }
        log_data(:no_data_found, data)
      end
    end
    vendor.update_column(:products_imported_at, Time.now)
    write_log_file
  end
end
