module Spree
  Product.class_eval do
    after_save :elasticsearch_index
    after_destroy :elasticsearch_delete

    private

    def elasticsearch_index
      __elasticsearch__.index_document
    end

    def elasticsearch_delete
      __elasticsearch__.delete_document
    end
  end
end
