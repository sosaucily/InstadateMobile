source 'https://rubygems.org'
gem 'sinatra', :require => 'sinatra/base'
gem 'thin'

gem 'datamapper', :require => 'data_mapper'
gem 'sqlite3'
gem 'dm-sqlite-adapter'
gem 'sinatra-reloader'
gem 'oauth', '0.4.5'

group :test do
  gem 'webmock'
  gem 'rack-test'
  gem 'rspec'
end

group :production do
  gem 'dm-postgres-adapter'
end