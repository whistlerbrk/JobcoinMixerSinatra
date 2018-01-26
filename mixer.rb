require 'sinatra'
require "sinatra/activerecord"
require "./jobcoin_api"
require "./mix_request"

db = ENV['APP_ENV'] == 'test' ? 'mixer-test.sqlite3' : "mixer.sqlite3"
set :database, { adapter: "sqlite3", database: db }

get '/' do
  erb :new
end

post '/' do
  @mix_request = MixRequest.new(distribution_addresses: params['addresses'])
  erb @mix_request.save ? :acknowledge : :new
end
