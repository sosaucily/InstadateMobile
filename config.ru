require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)

require 'json'
require 'logger'

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each {|file| require file }

require './instadate_mobile'

#log = File.new("sinatra.log", "a+")
#log.sync = true
#$stdout.reopen(log)
#$stderr.reopen(log)

run InstadateMobile
