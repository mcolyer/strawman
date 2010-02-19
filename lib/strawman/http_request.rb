module Strawman
  # = HttpRequest
  #
  # A simple wrapper for em-http-client's HttpRequest.
  #
  class HttpRequest
    include EventMachine::Deferrable

    def initialize(proxy_list, url)
      proxy_response = proxy_list.proxy
      proxy_response.callback do |proxy|
        @proxy = proxy
        @request = Transport.new(@proxy.proxy_url(url))
        succeed
      end
    end

    #
    # Handles get requests. Currently it accepts no arguments (ie query
    # parameters, http headers etc...).
    #
    def get
      http = @request.get :head => {"referer" => @proxy.referer}
      http.callback {
        # TODO: Munge the return output so that the stuff added by Glype is
        # removed
      }
      http
    end

    #
    # TODO: Implement this.
    #
    def post
      raise NotImplementedError
    end

    #
    # Can't and won't be implemented due to Glype not proxying these requests.
    #
    def put
      raise NotImplementedError
    end

    #
    # Can't and won't be implemented due to Glype not proxying these requests.
    #
    def delete
      raise NotImplementedError
    end

    #
    # Can't and won't be implemented due to Glype not proxying these requests.
    #
    def head
      raise NotImplementedError
    end
  end
end
