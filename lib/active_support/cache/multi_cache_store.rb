# frozen_string_literal: true

module ActiveSupport
  module Cache
    # A cache store implementation which doesn't actually store anything. Useful in
    # development and test environments where you don't want caching turned on but
    # need to go through the caching interface.
    #
    class MultiCacheStore < Store
      attr_reader :stores

      def initialize
        args = { memory_store: {}, redis_cache_store: { url: Rails.application.credentials.dig(:redis_server_url) } }

        options = args.keys.extract_options!
        super(options)

        @stores = []

        args.each do |arg, config_options|
          initialize_store(arg, config_options)
        end
      end

      def clear(options = nil)
        @stores[0].clear(options)
      end

      def cleanup(options = nil)
        @stores[0].cleanup(options)
      end

      def increment(name, amount = 1, options = nil)
        @stores[0].increment(name, amount, options)
      end

      def decrement(name, amount = 1, options = nil)
        @stores[0].decrement(name, amount, options)
      end

      def delete_matched(matcher, options = nil)
        @stores[0].delete_matched(matcher, options)
      end

      def self.supports_cache_versioning?
        true
      end

      protected

      def read_entry(key, **options)
        value = nil
        missed = []

        index_key = key.include?('spree/products/images') ? 1 : 0
        store = selected_cache_store(index_key)

        method = choose_method(store, :read_entry, :read)
        value = store.send(method, key, options)

        if value.nil?
          missed << store
        else
          Rails.logger.debug "Read from: #{store.class}"
        end


        if value
          missed.each do |store|
            method = choose_method(store, :write_entry, :write)
            store.send(method, key, value, options)
          end
        end

        value
      end

      def write_entry(key, entry, **options)
        index_key = key.include?('spree/products/images') ? 1 : 0
        store = selected_cache_store(index_key)

        method = choose_method(store, :write_entry, :write)
        store.send(method, key, entry, options)
        true
      end

      def delete_entry(key, **options)
        index_key = key.include?('spree/products/images') ? 1 : 0
        store = selected_cache_store(index_key)

        method = choose_method(store, :delete_entry, :delete)
        store.send(method, key, options)
      end

      private

      def choose_method(store, method1, method2)
        return method1 if store.respond_to? method1.to_sym
        return method2 if store.respond_to? method2.to_sym
        nil
      end

      def selected_cache_store(index_key = 0)
        @stores[index_key]
      end

      def initialize_store(arg, opts)
        stores << ActiveSupport::Cache.lookup_store(arg, opts)
      end

    end
  end
end
