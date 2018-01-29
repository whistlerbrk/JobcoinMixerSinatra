root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
$: << root

ENV['RACK_ENV'] = 'test'

require 'mixer'
require 'test/unit'
require 'rack/test'
require 'yaml'
require 'pry'

def fixtures
  return @fixtures if @fixtures
  root = File.expand_path(File.join(File.dirname(__FILE__), '..'))
  file = File.read(File.join(root, 'test', 'fixtures', 'mix_requests.yml'))
  @fixtures = YAML.load(ERB.new(file).result)
end

def mix_requests(identifier)
  attributes = fixtures[identifier.to_s]
  MixRequest.where(attributes).first_or_create
end
