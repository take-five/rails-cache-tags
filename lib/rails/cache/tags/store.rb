# coding: utf-8

require 'active_support/cache'
require 'active_support/concern'
require 'active_support/core_ext/module/aliasing'

require 'rails/cache/tags/set'

module Rails
  module Cache
    module Tags
      module Store
        extend ActiveSupport::Concern

        included do
          alias_method_chain :exist?, :tags
          alias_method_chain :read, :tags
          alias_method_chain :read_multi, :tags
          alias_method_chain :write, :tags
          alias_method_chain :fetch, :tags
        end

        # cache entry (for Dalli mainly)
        Entry = Struct.new(:value, :tags)

        def tag_set
          @tag_set ||= Set.new(self)
        end

        def read_with_tags(name, options = nil)
          result = read_without_tags(name, options)
          entry = tag_set.check(result)

          if entry
            entry
          else
            delete(name, options)

            nil
          end
        end

        def write_with_tags(name, value, options = nil)
          if options && options[:tags].present?
            tags = Tag.build(options[:tags])
            tags_hash = tags.each_with_object(Hash.new) do |tag, hash|
              hash[tag.name] = tag_set.current(tag)
            end

            value = Entry.new(value, tags_hash)
          end

          write_without_tags(name, value, options)
        end

        def exist_with_tags?(name, options = nil)
          exist_without_tags?(name, options) && !read(name, options).nil?
        end

        def read_multi_with_tags(*names)
          result = read_multi_without_tags(*names)

          names.extract_options!
          names.each_with_object(Hash.new) do |name, hash|
            hash[name.to_s] = tag_set.check(result[name.to_s])
          end
        end

        def fetch_with_tags(name, options = nil)
          return read(name, options) unless block_given?

          yielded = false

          result = fetch_without_tags(name, options) do
            yielded = true
            yield
          end

          if yielded
            result
          else # only :read occured
            # read occured, and result is fresh
            if (entry = tag_set.check(result))
              entry
            else # result is stale
              delete(name, options)
              fetch(name, options) { yield }
            end
          end
        end

        # Increment the version of tags, so all entries referring to the tags become invalid
        def delete_tag(*names)
          tags = Tag.build(names)
          tags.each { |tag| tag_set.expire(tag) }
        end
        alias delete_by_tag  delete_tag
        alias delete_by_tags delete_tag
        alias expire_tag     delete_tag
      end # module Store
    end # module Tags
  end # module Cache
end # module Rails