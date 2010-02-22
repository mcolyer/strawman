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
    # Handles HTTP GET requests. Query parameters should be specified on the
    # url given to HttpRequest.
    #
    # - opts: Takes a hash of options identical to EventMachine::HttpRequest.
    #
    # NOTE: most options will be ignored, except body data and proxy
    # information.
    #
    def get(opts={})
      opts = merge_referer_into_opts(opts)
      http = @request.get opts
      http.callback { munge_output }
      http
    end

    #
    # Handles HTTP POST requests. In for the post request to be a sent as a POST
    # request, atleast one POST field must be specified in the opts. Query
    # parameters should be specified on the url given to HttpRequest.
    #
    # - opts: Takes a hash of options identical to EventMachine::HttpRequest.
    #
    # NOTE: most options will be ignored, except body data and proxy
    # information.
    #
    def post(opts={})
      opts = merge_referer_into_opts(opts)
      http = @request.post opts
      http.callback { munge_output }
      http
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

  private
    def merge_referer_into_opts(opts)
      if opts.has_key? :head
        opts[:head].merge!({"referer" => @proxy.referer})
        opts
      else
        opts.merge({:head => {"referer" => @proxy.referer}})
      end
    end

    def munge_output()
    end
  end
end
