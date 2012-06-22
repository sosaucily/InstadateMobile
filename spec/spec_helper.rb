require 'bundler'
Bundler.require(:default, :test)
Dir[File.join(File.dirname(__FILE__), '..', 'lib', '*.rb')].each {|file| require file }

Sinatra::Base.set :environment, :test
Sinatra::Base.set :run, false
Sinatra::Base.set :raise_errors, true
Sinatra::Base.set :logging, false

require File.join(File.dirname(__FILE__), '..', 'instadate_mobile.rb')

DataMapper.setup(:default, "sqlite3::memory:")

RSpec.configure do |config|
  # Reset the database before each example.
  config.before(:each) do
    DataMapper.auto_migrate!
  end
end