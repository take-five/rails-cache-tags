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
        begin
          const_get(const).send(:include, Rails::Cache::Tags::Store)
        rescue LoadError, NameError
          # ignore
        end
      end
    end
  end
end

# Patch ActionController
ActiveSupport.on_load(:action_controller) do
  require 'rails/cache/tags/action_controller'

  ActionController::Base.send(:include, Rails::Cache::Tags::ActionController)
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