# coding: utf-8

module Rails
  module Cache
    module Tags
      module Store
        # cache entry (for Dalli mainly)
        Entry = Struct.new(:value, :tags)

        # patched +new+ method
        def new(*args, &block) #:nodoc:
          unless acts_like?(:cached_tags)
            extend ClassMethods
            include InstanceMethods

            alias_method_chain :read_entry, :tags
            alias_method_chain :write_entry, :tags
          end

          super
        end

        module ClassMethods #:nodoc:all:
          def acts_like_cached_tags?
          end
        end

        module InstanceMethods
          # Increment the version of tags, so all entries referring to the tags become invalid
          def delete_tag *names
            tags = Rails::Cache::Tag.build_tags(names)

            tags.each { |tag| tag.increment(self) } unless tags.empty?
          end
          alias delete_by_tag  delete_tag
          alias delete_by_tags delete_tag
          alias expire_tag     delete_tag

          protected
          def read_entry_with_tags(key, options) #:nodoc
            entry = read_entry_without_tags(key, options)

            # tags are supported only for ActiveSupport::Cache::Entry or Rails::Cache::Tags::Entry
            tags = if entry.is_a?(ActiveSupport::Cache::Entry) || entry.is_a?(Entry)
              entry.tags
            end

            if tags.is_a?(Hash) && tags.present?
              current_versions = fetch_tags(entry.tags.keys).values
              saved_versions   = entry.tags.values

              if current_versions != saved_versions
                delete_entry(key, options)

                return nil
              end
            end

            entry.is_a?(Entry) ?
                entry.value :
                entry
          end # def read_entry_with_tags

          def write_entry_with_tags(key, entry, options) #:nodoc:
            tags = Rails::Cache::Tag.build_tags Array.wrap(options[:tags]).flatten.compact

            if entry && tags.present?
              options[:raw] = false # force :raw => false

              # Dalli treats ActiveSupport::Cache::Entry as deprecated behavior, so we use our own Entry class
              entry = Entry.new(entry, nil) unless entry.is_a?(ActiveSupport::Cache::Entry)

              entry.tags = fetch_tags(tags).reduce(HashWithIndifferentAccess.new) do |hash, v|
                tag, value = v

                hash[tag.name] = value || tag.increment(self)

                hash
              end
            end

            write_entry_without_tags(key, entry, options)
          end # def write_entry_without_tags

          private
          # fetch tags versions from store
          # fetch ['user/1', 'post/2', 'country/2'] => [Tag('user/1') => 3, Tag('post/2') => 4, Tag('country/2') => nil]
          def fetch_tags(names) #:nodoc:
            tags = Rails::Cache::Tag.build_tags names
            stored = read_multi(*tags.map(&:to_key))

            # build hash
            tags.reduce(Hash.new) do |hash, t|
              hash[t] = stored[t.to_key]

              hash
            end
          end # def fetch_tags
        end # module InstanceMethods
      end # module Store
    end # module Tags
  end # module Cache
end # module Rails