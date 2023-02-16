module Spree
  module TrackersHelperDecorator
    def gtm
      @gtm ||= Spree::Tracker.current(:google_tag_manager, current_store)
    end

    def gtm_enabled?
      gtm.present?
    end
  end
end

::Spree::TrackersHelper.prepend Spree::TrackersHelperDecorator
