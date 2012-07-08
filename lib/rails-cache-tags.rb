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