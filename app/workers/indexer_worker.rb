class IndexerWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'compraagil_production_import', retry: false

  Logger = Sidekiq.logger.level == Logger::DEBUG ? Sidekiq.logger : nil

  def perform(operation, record_ids)
    logger.debug [operation, "IDs: #{record_ids}"]
    records = Spree::Product.where(id: record_ids)

    records.each do |record|
      case operation.to_s
      when /index/
        record.reindex
      when /delete/
        begin
          Spree::Product.searchkick_index.remove(record)
        rescue Elasticsearch::Transport::Transport::Errors::NotFound
          logger.debug 'Record not found'
        end
      else raise ArgumentError, "Unknown operation '#{operation}'"
      end
    end
  end
end
