require 'rubygems'
require 'eventmachine'
require 'em-http'
$LOAD_PATH << "../lib/"
require 'strawman'

log = Logger.new(STDOUT)
log.level = Logger::INFO

EventMachine.run {
  proxy_list = Strawman::ProxyList.new("http://whatismyip.org")
  sources_set = proxy_list.set_sources([Strawman::TwitterSource.new("proxy_sites")])

  sources_set.callback{
    http = Strawman::HttpRequest.new(proxy_list, 'http://goingtorain.com/').get
    http.callback {
      log.info http.response_header.inspect
      log.info http.response
      EventMachine.stop
    }
  }

  sources_set.errback{
    log.error "Something went wrong"
    EventMachine.stop
  }
}
