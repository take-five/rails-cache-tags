# coding: utf-8
require 'active_support'
require 'active_support/concern'
require 'active_support/cache'
require 'rails/cache/tags/store'

module Rails
  module Cache
    module Tags
      module Extensions
        module ActiveSupportCache
          extend ActiveSupport::Concern

          included do
            class << self
              alias_method :old_lookup_store, :lookup_store

              def lookup_store(*store_option)
                store = old_lookup_store(*store_option)
                store.class.send :include, Rails::Cache::Tags::Store

                store
              end
            end
          end
        end

        module ActiveSupportCacheEntry
          extend ActiveSupport::Concern

          included do
            attr_accessor :tags
          end
        end
      end
    end
  end
end

::ActiveSupport::Cache::Entry.send :include, ::Rails::Cache::Tags::Extensions::ActiveSupportCacheEntry
::ActiveSupport::Cache.send :include, ::Rails::Cache::Tags::Extensions::ActiveSupportCache

ActiveSupport.on_load(:action_controller) do
  require 'rails/cache/tags/action_controller'

  ::ActionController::Base.send(:include, Rails::Cache::Tags::ActionController)
end