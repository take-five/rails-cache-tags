require 'active_support'
require 'active_support/cache'

require 'rails/cache/tags/store'

module ActiveSupport
  module Cache
    class Entry
      attr_accessor :tags
    end

    # patch built-in stores
    [:FileStore, :MemCacheStore, :MemoryStore].each do |const|
      if const_defined?(const)
        const_get(const).send(:include, Rails::Cache::Tags::Store)
      end
    end
  end
end

# Patch ActionDispatch
ActiveSupport.on_load(:action_controller) do
  def expire_fragments_by_tags *args
    return unless cache_configured?

    cache_store.delete_tag *args
  end
  alias expire_fragments_by_tag expire_fragments_by_tags
end

# Patch Dalli store
begin
  require 'dalli'
  require 'dalli/version'

  if Dalli::VERSION.to_f > 2
    require 'active_support/cache/dalli_store'

    ActiveSupport::Cache::DalliStore.send(:include, Rails::Cache::Tags::Store)
  end
rescue LoadError, NameError
  # ignore
end