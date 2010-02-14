require 'rubygems'
require 'eventmachine'
require 'em-http'
require 'lib/strawman'

EventMachine.run {
  proxy_list = Strawman::ProxyList.new
  sources_set = proxy_list.set_sources([Strawman::TwitterSource.new("proxy_sites")])
  sources_set.callback{
    http = Strawman::HttpRequest.new('http://whatismyip.org/').get
    http.callback {
      p http.response
      EventMachine.stop
    }
  }
}
