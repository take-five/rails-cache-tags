# coding: utf-8

require 'rails/cache/tags/tag'

module Rails
  module Cache
    module Tags
      class Set
        KEY_PREFIX = '_tags'

        # @param [ActiveSupport::Cache::Store] cache
        def initialize(cache)
          @cache = cache
        end

        def current(tag)
          @cache.fetch_without_tags(tag.to_key) { 1 }.to_i
        end

        def expire(tag)
          version = current(tag) + 1

          @cache.write_without_tags(tag.to_key, version, :expires_in => nil)

          version
        end

        def check(entry)
          return entry unless entry.is_a?(Store::Entry)
          return entry.value if entry.tags.blank?

          tags = Tag.build(entry.tags.keys)

          saved_versions = entry.tags.values.map(&:to_i)
          current_versions = read_multi(tags).values.map(&:to_i)

          saved_versions == current_versions ? entry.value : nil
        end

        private
        def read_multi(tags)
          @cache.read_multi_without_tags(*Array.wrap(tags).map(&:to_key))
        end
      end # class Set
    end # module Tags
  end # module Cache
end # module Rails