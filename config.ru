require 'rubygems'
require 'bundler'
require 'sqlite3'
require 'data_mapper'
require 'dm-serializer'

require 'json'
require 'logger'

require './lib/activity'
require './lib/story'
require './lib/venue_helpers'
require './lib/yelp'
require './lib/upcoming'

Bundler.require

require './instadate_mobile'

log = File.new("sinatra.log", "a+")
log.sync = true
$stdout.reopen(log)
$stderr.reopen(log)

run InstadateMobile

