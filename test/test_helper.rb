root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$: << root

ENV['APP_ENV'] = 'test'
ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'mixer'
