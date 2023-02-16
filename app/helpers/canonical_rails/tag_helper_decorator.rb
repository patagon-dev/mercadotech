module CanonicalRails
  module TagHelperDecorator
    def trailing_slash_needed?
      request.params.key?('action') && CanonicalRails.sym_collection_actions.include?(request.params['action'].to_sym) && request.params['action'] != 'index'
    end
  end
end

::CanonicalRails::TagHelper.prepend CanonicalRails::TagHelperDecorator