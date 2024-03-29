ENV['RACK_ENV'] = 'test'
require 'webmock/rspec'
require 'bundler'
Bundler.require(:default, :test)
Dir[File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')].each {|file| require file }
Dir[File.join(File.dirname(__FILE__), 'spec_helpers', '*')].each do |spec_helper|
  require spec_helper
end

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require 'logger'
require File.join(File.dirname(__FILE__), '..', 'instadate_mobile.rb')

DataMapper.setup(:default, "sqlite3::memory:")

RSpec.configure do |config|
  # Reset the database before each example.
  config.before(:each) do
    DataMapper.auto_migrate!
  end
  
  config.treat_symbols_as_metadata_keys_with_true_values = true
end

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.configure_rspec_metadata!
  c.default_cassette_options = { :record => :new_episodes }
  # c.filter_sensitive_data("<API_KEY>") { MyAPIClient.api_key }
end
