require 'active_storage/service/s3_service'

module ActiveStorage
  module Service::S3ServiceDecorator

    def initialize(bucket:, upload: {}, public: false, **options)
      @client = Aws::S3::Resource.new(**options)
      @bucket = @client.bucket(bucket)

      @multipart_upload_threshold = upload.delete(:multipart_threshold) || 100.megabytes
      @public = public

      upload = { cache_control: 'max-age=31536000' } # Added cache header
      @upload_options = upload
      @upload_options[:acl] = "public-read" if public?
    end

    # Override to provide virtual host
    def url(key, expires_in:, filename:, disposition:, content_type:)
      instrument :url, key: key do |payload|
        generated_url = object_for(key).presigned_url :get, expires_in: expires_in.to_i,
                                                            response_content_disposition: content_disposition_with(type: disposition, filename: filename),
                                                            response_content_type: content_type, virtual_host: bucket.name

        payload[:url] = generated_url

        generated_url
      end
    end
  end
end

::ActiveStorage::Service::S3Service.prepend(ActiveStorage::Service::S3ServiceDecorator)
