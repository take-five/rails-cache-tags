# coding: utf-8

require 'bundler/setup'

require 'simplecov'

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.order = 'random'

  config.around(:each, :memcache) do |example|
    require 'memcache'
    begin
      MemCache.new('localhost:11211').stats
      example.run
    rescue MemCache::MemCacheError
      $stderr.puts 'Skipping Memcached tests. Start memcached and try again.'
    end
  end
end

SimpleCov.start 'test_frameworks'

require 'rails-cache-tags'