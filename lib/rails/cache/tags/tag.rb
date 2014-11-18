module Rails
  module Cache
    module Tags
      class Tag
        KEY_PREFIX = '_tags'

        # {:post => ['1', '2', '3']} => [Tag(post/1), Tag(post/2), Tag(post/3)]
        # {:post => 1, :user => 2} => [Tag(post/1), Tag(user/2)]
        # ['post/1', 'post/2', 'post/3'] => [Tag(post/1), Tag(post/2), Tag(post/3)]
        def self.build(names)
          case names
            when NilClass then nil
            when Hash then names.map do |key, value|
              Array.wrap(value).map { |v| new([key, v]) }
            end.flatten
            when Enumerable then names.map { |v| build(v) }.flatten
            when self then names
            else [new(names)]
          end
        end

        attr_reader :name

        # Tag constructor
        def initialize(name)
          @name = ActiveSupport::Cache.expand_cache_key(name)
        end

        # real cache key
        def to_key
          [KEY_PREFIX, @name].join('/')
        end
      end
    end
  end
end