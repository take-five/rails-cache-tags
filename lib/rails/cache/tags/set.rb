# coding: utf-8

require 'rails/cache/tags/tag'
require 'rails/cache/tags/local_cache'

module Rails
  module Cache
    module Tags
      class Set
        # @param [ActiveSupport::Cache::Store] store
        def initialize(store)
          @store = store
          @tags_cache = LocalCache.new
        end

        def current(tag)
          key = tag.to_key
          @tags_cache.fetch(key) do
            @store.fetch_without_tags(key) { 1 }.to_i
          end
        end

        def expire(tag)
          version = current(tag) + 1
          @store.write_without_tags(tag.to_key, version, :expires_in => nil)

          version
        end

        def check(entry)
          return entry unless entry.is_a?(Store::Entry)
          return entry.value if entry.tags.blank?

          tags = Tag.build(entry.tags.keys)

          saved_versions = entry.tags.values.map(&:to_i)

          saved_versions == current_versions(tags) ? entry.value : nil
        end

        private

        def current_versions(tags)
          keys = Array.wrap(tags).map(&:to_key)
          versions = keys.inject({}) do |memo, key|
            if @tags_cache.exist?(key)
              memo[key] = @tags_cache[key]
            else
              memo[key] = nil
            end

            memo
          end

          keys = versions.map { |key, version| key if version.nil? }.compact
          @store.read_multi_without_tags(*keys).each do |key, value|
            @tags_cache[key] = value
            versions[key] = value
          end if keys.present?

          versions.values.map(&:to_i)
        end

        def tags_cache
          @tags_cache
        end
      end # class Set
    end # module Tags
  end # module Cache
end # module Rails