source 'https://rubygems.org'
gem 'sinatra', :require => 'sinatra/base'
gem 'thin'

gem 'datamapper', :require => 'data_mapper'
gem 'sqlite3'
gem 'dm-sqlite-adapter'
gem 'oauth', '0.4.5'
gem "rest-client"
gem "json"
gem 'newrelic_rpm'
gem 'sinatra-partial'

gem 'rake'

group :development do
  gem 'sinatra-reloader'
end

group :test do
  gem 'vcr'
  gem 'webmock'
  gem 'rack-test'
  gem 'rspec'
  gem 'timecop'
end

group :production do
  gem 'dm-postgres-adapter'
end