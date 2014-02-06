module Rails
  module Cache
    module Tags
      module ActionController
        def expire_fragments_by_tags(*args)
          return unless cache_configured?

          cache_store.delete_tag(*args)
        end
        alias_method :expire_fragments_by_tag, :expire_fragments_by_tags
      end
    end
  end
end