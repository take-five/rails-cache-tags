#!/usr/bin/env rake
require "bundler/gem_tasks"

desc 'Run tests'
task :test do
  test_dir = File.expand_path(File.join("..", "test"), __FILE__)

  Dir[File.join(test_dir, '**', '*_test.rb')].each { |f| require f }
  require 'minitest/autorun'
end