# Synopsys

Tagged caching support within your Rails application. Tested against Rails 3.0, Rails 3.1 and Rails 3.2
[Dalli](https://github.com/mperham/dalli) store is also supported!

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

More realistic example:
```ruby
class PostsController < ApplicationController
  def index
    @posts = cache.read("posts") || begin
      posts_from_db = Post.all

      cache.write "posts", :tags => {:post => posts_from_db.map(&:id)}

      posts_from_db
    end
  end

  def show
    id = params[:id]

    @post = cache.fetch(["post", id], :tags => {:post => id}) do
      Post.find(id)
    end
  end

  def update
    @post = Post.find(params[:id])

    if @post.update_attributes
      cache.delete_tag :post => @post.id
    end
  end
end
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
4. Write tests!
5. Run tests against all major version of Rails starting from 3.0
6. Push to the branch (`git push origin my-new-feature`)
7. Create new Pull Request