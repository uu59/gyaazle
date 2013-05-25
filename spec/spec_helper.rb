# -- coding: utf-8

require "rubygems"
require "bundler/setup"

require "simplecov"
require 'coveralls'
Coveralls.wear!

if ENV["COVERAGE"]
  # Coveralls overwrite NilFomatter
  SimpleCov.formatter = SimpleCov::Formatter::HTMLFormatter
  SimpleCov.start do
    add_filter "/spec/"
  end
end
Bundler.require :default, :test
require "rspec-expectations"
require "rspec/matchers/built_in/be"

Dir["./spec/support/**/*.rb"].each{|file| require file }


require File.expand_path("../../lib/gyaazle.rb", __FILE__)

RSpec.configure do |config|
end
# -- coding: utf-8


