require "active_support/cache"

require "action_controller"

require "rails/cache/tag"
require "rails/cache/tags/store"

# Patch ActiveSupport common store
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

# Patch ActionDispatch
class ActionController::Base < ActionController::Metal
  def expire_fragments_by_tags *args
    return unless cache_configured?

    cache_store.delete_tag *args
  end
  alias expire_fragments_by_tag expire_fragments_by_tags
end

# Patch Dalli store
begin
  require "dalli"
  require "dalli/version"

  if Dalli::VERSION.to_f > 2
    require "active_support/cache/dalli_store"

    ActiveSupport::Cache::DalliStore.extend(Rails::Cache::Tags::Store)
  end
rescue LoadError, NameError
  # ignore
end