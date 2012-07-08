require "active_support/cache"

require "rails/cache/tag"
require "rails/cache/tags/store"

module ActiveSupport
  module Cache
    class Store
      extend Rails::Cache::Tags::Store
    end

    class Entry
      attr_accessor :tags
    end
  end
end

if defined?(ActionController::Base)
  class ActionController::Base < ActionController::Metal
    def expire_fragments_by_tags *args
      return unless cache_configured?

      cache_store.delete_tag *args
    end
    alias expire_fragments_by_tag expire_fragments_by_tags
  end
end