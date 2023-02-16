namespace :add do
  desc 'Update mime type for pdf documents on S3 [AWS CLI IS REQUIRED]'
  task metadata_to_s3_files: :environment do
    label_keys = Spree::ShipmentLabel.all.map { |ship| ship.enviame_label.attachment }.compact.map { |label| label.blob.key }
    invoice_keys = Spree::Invoice.all.map { |inv| inv.document.attachment }.compact.map { |invoice| invoice.blob.key }
    keys = label_keys + invoice_keys
    s3_bucket_name = Rails.application.credentials.dig(:aws, :bucket_name)

    # AWS CLI PATH on server /usr/local/bin/aws
    keys.each do |key|
      system "aws s3 cp s3://#{s3_bucket_name}/#{key} s3://#{s3_bucket_name}/#{key} --content-type 'application/pdf' --cache-control max-age=315360000 --acl public-read  --metadata-directive REPLACE"
    rescue Exception => e
      puts "Exception occurs: #{e} for KEY: #{key}"
    end
  end
end
