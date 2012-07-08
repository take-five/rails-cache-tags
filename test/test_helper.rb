require "bundler/setup"

require 'active_support/all'
require 'active_support/test_case'
require "active_support/core_ext"
require 'active_support/core_ext/kernel/reporting'
require 'active_support/core_ext/string/encoding'
require 'simplecov'

silence_warnings do
  Encoding.default_internal = "UTF-8"
  Encoding.default_external = "UTF-8"
end

def uses_memcached(test_name)
  require 'memcache'
  begin
    MemCache.new('localhost:11211').stats
    yield
  rescue MemCache::MemCacheError
    $stderr.puts "Skipping #{test_name} tests. Start memcached and try again."
  end
end

ActiveSupport::Deprecation.debug = true

SimpleCov.start { add_filter 'test' }
require 'rails-cache-tags'