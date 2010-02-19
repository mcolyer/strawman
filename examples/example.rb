require 'rubygems'
require 'eventmachine'
require 'em-http'
$LOAD_PATH << "../lib/"
require 'strawman'
require 'logger'

log = Logger.new(STDOUT)
log.level = Logger::INFO

EventMachine.run {
  proxy_list = Strawman::ProxyList.new("http://whatismyip.org")
  proxy_list.load("proxies") if File.exist?("proxies")
  sources_set = proxy_list.add_sources([Strawman::TwitterSource.new("proxy_sites")])

  sources_set.callback{
    proxy_list.save("proxies")
    request = Strawman::HttpRequest.new(proxy_list, 'http://goingtorain.com/')
    request.callback {
      http = request.get
      http.callback {
        log.info http.response_header.inspect
        log.info http.response
        EventMachine.stop
      }
    }
    request.errback{
      log.error "No available proxies"
    }
  }

  sources_set.errback{
    log.error "Something went wrong"
    EventMachine.stop
  }
}
