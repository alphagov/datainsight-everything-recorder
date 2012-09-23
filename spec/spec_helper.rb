require 'rspec'
require 'bundler/setup'
Bundler.require

ENV['RACK_ENV'] = 'test'

Datainsight::Logging.configure(:env => :test)