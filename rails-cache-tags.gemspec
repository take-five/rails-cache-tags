# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails/cache/tags/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name          = 'rails-cache-tags'
  gem.version       = Rails::Cache::Tags::VERSION

  gem.authors       = ['Alexei Mikhailov']
  gem.email         = %W(amikhailov83@gmail.com)
  gem.description   = %q{Tagged caching support for Rails}
  gem.summary       = %q{Tagged caching support for Rails}
  gem.homepage      = 'https://github.com/take-five/rails-cache-tags'


  gem.files         = `git ls-files -- lib/*`.split("\n")
  gem.test_files    = `git ls-files -- spec/*`.split("\n")
  gem.require_paths = %W(lib)

  gem.add_dependency 'activesupport', '>= 3.0'
  gem.add_dependency 'request_store'

  gem.add_development_dependency 'i18n'
  gem.add_development_dependency 'appraisal'
  gem.add_development_dependency 'minitest', '~> 4.2'
  gem.add_development_dependency 'memcache-client'
  gem.add_development_dependency 'rack'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'simplecov'
  gem.add_development_dependency 'dalli', '>= 2.0'
  gem.add_development_dependency 'rspec'
end
