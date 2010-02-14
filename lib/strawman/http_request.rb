module Strawman
  class HttpRequest
    def initialize(proxy_list, url)
      @proxy = proxy_list.proxy
      proxied_url = @proxy.proxy_url(url)
      @request = EventMachine::HttpRequest.new(proxied_url)
    end
    
    def get
      http = @request.get :head => {"referer" => @proxy.referer}
      http.callback {
        # TODO: Munge the return output
        puts http.response_header.inspect
      }
      http
    end
  end
end
