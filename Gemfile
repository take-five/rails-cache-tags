source 'https://rubygems.org'

# Specify your gem's dependencies in rails-cache-tags.gemspec
gemspec

gem 'rack', '< 2'

if ENV['DALLI']
  if ENV['DALLI'] == '2.2'
    gem 'dalli', '~> 2.2.0'
  else
    gem 'dalli', '~> 2.7.0'
  end
end