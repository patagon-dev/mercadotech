module Spree::Admin::StockLocationsControllerDecorator
  def stock_location_report
    file_path = "tmp/#{@stock_location.name}_report.xls"
    workbook = @stock_location.to_xls_worksheet
    workbook.write file_path
    send_file file_path, type: "application/xls"
  end
end

Spree::Admin::StockLocationsController.prepend Spree::Admin::StockLocationsControllerDecorator
