require 'rubygems'
require 'bundler'
require 'sqlite3'
require 'data_mapper'
require 'dm-serializer'

require 'json'
require 'logger'

require './classes/activity'
require './classes/story'
require './classes/venue_helpers'
require './classes/yelp'
require './classes/upcoming'

Bundler.require

require './instadate_mobile'

log = File.new("sinatra.log", "a+")
log.sync = true
$stdout.reopen(log)
$stderr.reopen(log)

run InstadateMobile

