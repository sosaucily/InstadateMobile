require 'rubygems'
require 'bundler'
Bundler.require(:default, :development)
require 'logger'
require 'psych'

Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each {|file| require file }

require './instadate_mobile'

run InstadateMobile