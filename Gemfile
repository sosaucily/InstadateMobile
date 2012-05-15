source 'https://rubygems.org'
gem "sinatra", :require => "sinatra/base"
gem 'thin'

gem 'datamapper'

group :development do
  gem 'sqlite3'
  gem 'dm-sqlite-adapter'
end

group :test do
  gem 'webmock'
end

group :production do
  gem 'pg'
  gem 'dm-postgres-adapter'
end

gem 'sinatra-reloader'

gem 'oauth', '0.4.5'