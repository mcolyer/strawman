require 'rubygems'
require 'eventmachine'
require 'em-http'
$LOAD_PATH << "../lib/"
require 'strawman'

EventMachine.run {
  proxy_list = Strawman::ProxyList.new
  sources_set = proxy_list.set_sources([Strawman::TwitterSource.new("proxy_sites")])
  sources_set.callback{
    http = Strawman::HttpRequest.new(proxy_list, 'http://goingtorain.com/').get
    http.callback {
      p http.response
      EventMachine.stop
    }
  }
}
