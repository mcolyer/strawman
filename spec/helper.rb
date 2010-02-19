require 'rubygems'
require 'spec'

require 'eventmachine'
require 'em-http'
require 'em-http/mock'
require 'json'
require 'cgi'

$LOAD_PATH.unshift File.dirname(__FILE__) + '/../lib/'
