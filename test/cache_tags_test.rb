$:.unshift(File.dirname(__FILE__))

require "test_helper"
require "caching_test"

module CacheTagsBehavior
  def test_read_and_write_with_tags
    @cache.write("foo", "bar", :tags => "baz")
    assert_equal 'bar', @cache.read('foo')
  end

  def test_read_after_tag_deleted
    @cache.write("foo", "bar", :tags => "baz")
    @cache.delete_tag("baz")

    assert_nil @cache.read("foo")
  end

  def test_read_after_another_tag_deleted
    @cache.write("foo", "bar", :tags => "baz")
    @cache.delete_tag("fu")

    assert_equal 'bar', @cache.read('foo')
  end

  def test_read_and_write_with_multiple_tags
    @cache.write("foo", "bar", :tags => [:baz, :kung])
    assert_equal 'bar', @cache.read('foo')
  end

  def test_read_after_one_of_tags_deleted
    @cache.write("foo", "bar", :tags => [:baz, :kung])
    @cache.delete_tag :kung

    assert_nil @cache.read("foo")
  end

  def test_read_after_another_of_multiple_tags_deleted
    @cache.write("foo", "bar", :tags => [:baz, :kung])
    @cache.delete_tag("fu")

    assert_equal 'bar', @cache.read('foo')
  end

  def test_read_with_small_default_expiration_time
    cache = if is_a?(FileStoreTest)
      @cache.class.new @cache.cache_path, :expires_in => 0.001
    else
      @cache.class.new :expires_in => 0.001
    end

    cache.write("foo", "bar", :tags => "baz", :expires_in => 2)
    sleep 0.02

    assert_equal 'bar', cache.read('foo')
  end

  def test_exists_with_tags
    @cache.write("foo", "bar", :tags => "baz")
    assert_equal @cache.exist?("foo"), true

    @cache.delete_tag("baz")

    assert_equal @cache.exist?("foo"), false
  end

  def test_read_and_write_with_tags_hash
    @cache.write("foo", "bar", :tags => {:baz => 1})
    assert_equal 'bar', @cache.read('foo')
  end

  def test_read_and_write_with_hash_of_tags
    @cache.write("foo", "bar", :tags => {:baz => 1})
    assert_equal 'bar', @cache.read('foo')

    @cache.delete_tag :baz => 2
    assert_equal 'bar', @cache.read('foo')

    @cache.delete_tag :baz => 1

    assert_nil @cache.read('foo')
  end

  def test_read_and_write_with_tags_array_of_objects
    tag1 = 1.day.ago
    tag2 = 2.days.ago

    @cache.write("foo", "bar", :tags => [tag1, tag2])
    assert_equal 'bar', @cache.read('foo')

    @cache.delete_tag tag2

    assert_nil @cache.read('foo')
  end
end

[FileStoreTest, MemoryStoreTest, MemCacheStoreTest, DalliStoreTest].each do |klass|
  klass.send :include, CacheTagsBehavior
end