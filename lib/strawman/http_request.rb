module Strawman
  class HttpRequest
    def initialize(proxy_list, url)
      @proxy = proxy_list.proxy
      proxied_url = @proxy.proxy_url(url)
      @request = Transport.new(proxied_url)
    end

    def get
      http = @request.get :head => {"referer" => @proxy.referer}
      http.callback {
        # TODO: Munge the return output so that the stuff added by Glype is
        # removed
      }
      http
    end
  end
end
