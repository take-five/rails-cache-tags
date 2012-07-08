module Rails
  module Cache
    class Tag #:nodoc:all:
      KEY_PREFIX = '_tags'

      class << self
        # {:post => ['1', '2', '3']} => [Tag(post:1), Tag(post:2), Tag(post:3)]
        # {:post => 1, :user => 2} => [Tag(post:1), Tag(user:2)]
        # ['post:1', 'post:2', 'post:3'] => [Tag(post:1), Tag(post:2), Tag(post:3)]
        def build_tags(names)
          case names
            when NilClass then nil
            when Hash then names.map do |key, value|
              Array.wrap(value).map { |v| new([key, v]) }
            end.flatten
            when Enumerable then names.map { |v| build_tags(v) }.flatten
            when self then names
            else [new(names)]
          end
        end
      end

      attr_reader :name

      # Tag constructor, accepts String, Symbol and Array
      def initialize(name)
        @name = case name
          when String, Symbol then name
          when Array then name.join(':')
          else raise ArgumentError
        end
      end

      # real cache key
      def to_key
        [KEY_PREFIX, name].join('/')
      end

      # read tag's version from +store+
      def fetch(store)
        store.read(to_key)
      end

      # increment tag's version inside +store+
      def increment(store)
        current = fetch(store)

        version = if current.is_a?(Fixnum)
          current + 1
        else
          1
        end

        store.write(to_key, version, :expires_in => nil)

        version
      end
    end # class Tag
  end # module Cache
end # module Rails