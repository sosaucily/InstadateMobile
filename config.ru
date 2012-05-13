require 'rubygems'
require 'bundler'
require 'sqlite3'
require 'data_mapper'

require './lib/activity'
require './lib/story'

Bundler.require

require './instadate_mobile'
run InstadateMobile