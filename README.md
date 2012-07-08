# Synopsys

Tagged caching support within your Rails application.

# Installation

Add this line to your application's Gemfile:

    gem 'rails-cache-tags'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rails-cache-tags

# Usage

Anywhere:

```ruby
cache = Rails.cache

cache.write "foo", "bar", :tags => %w(baz foo)
cache.read "foo" # => "bar"

cache.delete_tag "baz"
cache.read "foo" => nil
```

In your controller:
```ruby
class PostController < ActionController::Base
  def update
    @post = Post.find_by_id(params[:id])

    if @post.update_attributes(params)
      expire_fragments_by_tags :post => @post.id
    else
      render :edit
    end
  end
end
```

# Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
