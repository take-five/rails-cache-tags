# coding: utf-8

require 'request_store'

module Rails
  module Cache
    module Tags
      class LocalCache
        delegate :fetch, :exist?, :[], :[]=, to: :store

        def clear
          store.clear!
        end

        private

        def store
          if RequestStore.active?
            RequestStore
          else
            DummyStore
          end
        end

        class DummyStore
          def self.fetch(_)
            yield
          end

          def self.clear!; end
          def self.exist?(_); end
          def self.[](_); end
          def self.[]=(*); end
        end
      end # class LocalCache
    end # module Tags
  end # module Cache
end # module Rails
