# -*- encoding: utf-8 -*-
require File.expand_path('../lib/rails/cache/tags/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Alexei Mikhailov"]
  gem.email         = %W(amikhailov83@gmail.com)
  gem.description   = %q{TODO: Write a gem description}
  gem.summary       = %q{TODO: Write a gem summary}
  gem.homepage      = "https://github.com/take-five/rails-cache-tags"

  gem.files         = `git ls-files`.split($\)
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rails-cache-tags"
  gem.require_paths = %W(lib)
  gem.version       = Rails::Cache::Tags::VERSION

  gem.add_dependency "activesupport", ">= 3.0"
  gem.add_dependency "actionpack", ">= 3.0"

  gem.add_development_dependency 'minitest', '~> 3.2'
  gem.add_development_dependency 'memcache-client'
  gem.add_development_dependency 'rack'
  gem.add_development_dependency 'mocha'
  gem.add_development_dependency 'simplecov'
end
