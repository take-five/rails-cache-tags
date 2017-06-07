# coding: utf-8

require 'spec_helper'
require 'fileutils'
require 'active_support/core_ext'

describe Rails::Cache::Tags do
  shared_examples 'cache with tags support for' do |object|
    before { cache.clear }

    def assert_read(key, object)
      expect(cache.exist?(key, options)).to eq !!object
      expect(cache.read(key, options)).to eq object
    end

    def assert_blank(key)
      assert_read key, nil
    end

    it 'reads and writes a key with tags' do
      cache.write('foo', object, options.merge(:tags => 'baz'))

      assert_read 'foo', object
    end

    it 'deletes a key if tag is deleted' do
      cache.write('foo', object, options.merge(:tags => 'baz'))
      cache.delete_tag 'baz'

      assert_blank 'foo'
    end

    it 'reads a key if another tag was deleted' do
      cache.write('foo', object, options.merge(:tags => 'baz'))
      cache.delete_tag 'fu'

      assert_read 'foo', object
    end

    it 'reads and writes if multiple tags given' do
      cache.write('foo', object, options.merge(:tags => [:baz, :kung]))

      assert_read 'foo', object
    end

    it 'deletes a key if one of tags is deleted' do
      cache.write('foo', object, options.merge(:tags => [:baz, :kung]))
      cache.delete_tag :kung

      assert_blank 'foo'
    end

    it 'does not delete a nonexistent key' do
      expect(cache).not_to receive(:delete).with('not_exist_key', options)
      expect(cache.read('not_exist_key', options)).to eq nil
    end

    #it 'does not read a key if it is expired' do
    #  ttl = 0.01
    #  # dalli does not support float TTLs
    #  ttl *= 100 if cache.class.name == 'ActiveSupport::Cache::DalliStore'
    #
    #  cache.write 'foo', object, :tags => [:baz, :kung], :expires_in => ttl
    #
    #  sleep ttl * 2
    #
    #  assert_blank 'foo'
    #end

    context 'when no tags local cache' do
      before do
        RequestStore.end!
      end

      it 'reads and writes a key if hash of tags given' do
        cache.write('foo', object, options.merge(:tags => {:baz => 1}))
        assert_read 'foo', object

        cache.delete_tag :baz => 2
        assert_read 'foo', object

        cache.delete_tag :baz => 1
        assert_blank 'foo'
      end

      it 'reads and writes a key if array of object given as tags' do
        tag1 = 1.day.ago
        tag2 = 2.days.ago

        cache.write 'foo', object, options.merge(:tags => [tag1, tag2])
        assert_read 'foo', object

        cache.delete_tag tag1
        assert_blank 'foo'
      end

      it 'reads multiple keys with tags check' do
        cache.write 'foo', object, options.merge(:tags => :bar)
        cache.write 'bar', object, options.merge(:tags => :baz)

        assert_read 'foo', object
        assert_read 'bar', object

        cache.delete_tag :bar

        assert_blank 'foo'
        assert_read 'bar', object

        expect(cache.read_multi('foo', 'bar', options)).to eq('foo' => nil, 'bar' => object)
      end

      it 'fetches key with tag check' do
        cache.write 'foo', object, options.merge(:tags => :bar)

        expect(cache.fetch('foo', options) { 'baz' }).to eq object
        expect(cache.fetch('foo', options)).to eq object

        cache.delete_tag :bar

        expect(cache.fetch('foo', options)).to be_nil
        expect(cache.fetch('foo', options.merge(:tags => :bar)) { object }).to eq object
        assert_read 'foo', object

        cache.delete_tag :bar

        assert_blank 'foo'
      end
    end

    context 'when tags local cache' do
      before do
        RequestStore.clear!
        RequestStore.begin!
      end

      after do
        RequestStore.end!
      end

      it 'reads and writes a key if hash of tags given' do
        cache.write('foo', object, options.merge(:tags => {:baz => 1}))
        assert_read 'foo', object

        cache.delete_tag :baz => 2
        assert_read 'foo', object

        cache.delete_tag :baz => 1
        assert_read 'foo', object

        cache.tag_set.send(:tags_cache).clear
        assert_blank 'foo'
      end

      it 'reads and writes a key if array of object given as tags' do
        tag1 = 1.day.ago
        tag2 = 2.days.ago

        cache.write 'foo', object, options.merge(:tags => [tag1, tag2])
        assert_read 'foo', object

        cache.delete_tag tag1
        assert_read 'foo', object

        cache.tag_set.send(:tags_cache).clear
        assert_blank 'foo'
      end

      it 'reads multiple keys with tags check' do
        cache.write 'foo', object, options.merge(:tags => :bar)
        cache.write 'bar', object, options.merge(:tags => :baz)

        assert_read 'foo', object
        assert_read 'bar', object

        cache.delete_tag :bar

        assert_read 'foo', object

        cache.tag_set.send(:tags_cache).clear
        assert_blank 'foo'
        assert_read 'bar', object

        expect(cache.read_multi('foo', 'bar', options)).to eq('foo' => nil, 'bar' => object)
      end

      it 'fetches key with tag check' do
        cache.write 'foo', object, options.merge(:tags => :bar)

        expect(cache.fetch('foo', options) { 'baz' }).to eq object
        expect(cache.fetch('foo', options)).to eq object

        cache.delete_tag :bar

        expect(cache.fetch('foo', options)).to eq object

        cache.tag_set.send(:tags_cache).clear

        expect(cache.fetch('foo', options)).to be_nil
        expect(cache.fetch('foo', options.merge(:tags => :bar)) { object }).to eq object
        assert_read 'foo', object

        cache.delete_tag :bar
        assert_read 'foo', object

        cache.tag_set.send(:tags_cache).clear
        assert_blank 'foo'
      end
    end
  end

  class ComplexObject < Struct.new(:value)
  end

  SCALAR_OBJECT = 'bar'
  COMPLEX_OBJECT = ComplexObject.new('bar')

  shared_examples 'cache with tags support' do |*tags|
    shared_examples 'cache with tags support with options' do
      context '', tags do
        include_examples 'cache with tags support for', SCALAR_OBJECT
        include_examples 'cache with tags support for', COMPLEX_OBJECT

        # test everything with locale cache
        include_examples 'cache with tags support for', SCALAR_OBJECT do
          include ActiveSupport::Cache::Strategy::LocalCache

          around(:each) do |example|
            if cache.respond_to?(:with_local_cache)
              cache.with_local_cache { example.run }
            end
          end
        end

        include_examples 'cache with tags support for', COMPLEX_OBJECT do
          include ActiveSupport::Cache::Strategy::LocalCache

          around(:each) do |example|
            cache.with_local_cache { example.run }
          end
        end
      end
    end

    context "without namespace option" do
      let(:options) { {} }
      include_examples 'cache with tags support with options'
    end

    context "with namespace option" do
      let(:options) { {namespace: 'namespace'} }
      include_examples 'cache with tags support with options'
    end
  end

  it_should_behave_like 'cache with tags support', :memory_store do
    let(:cache) { ActiveSupport::Cache.lookup_store(:memory_store, :expires_in => 60, :size => 100) }
  end

  it_should_behave_like 'cache with tags support', :file_store do
    let(:cache_dir) { File.join(Dir.pwd, 'tmp_cache') }
    before { FileUtils.mkdir_p(cache_dir) }
    after  { FileUtils.rm_rf(cache_dir) }

    let(:cache) { ActiveSupport::Cache.lookup_store(:file_store, cache_dir, :expires_in => 60) }
  end

  it_should_behave_like 'cache with tags support', :memcache, :mem_cache_store do
    let(:cache) { ActiveSupport::Cache.lookup_store(:mem_cache_store, :expires_in => 60) }
  end

  it_should_behave_like 'cache with tags support', :memcache, :dalli_store do
    let(:cache) { ActiveSupport::Cache.lookup_store(:dalli_store, :expires_in => 60) }
  end
end