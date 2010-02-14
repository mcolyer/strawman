module Strawman
  class Proxy
  end

  class GlypeProxy < Proxy
    def initialize(url)
      @root_url = url
      @valid = false
    end

    def valid?
      @valid
    end

    def validate
      url = proxy_url("http://whatismyip.org")
      # FIXME: This only validate proxies that don't require a unique session
      # cookie which is retrieved by going to the root page and looking for the
      # s cookie.
      http = EventMachine::HttpRequest.new(url).get :head => {'referer' => @root_url}
      http.callback {
        @valid = true if http.response_header.status == 200
      }

      http
    end

    def to_s
      "<GlypeProxy #{@root_url}>"
    end

    def referer
      @root_url
    end

    def proxy_url(url)
      URI.join @root_url, proxy_path(url)
    end

    def proxy_path(url)
      encoded_url = CGI.escape(Base64.encode64(url[4..-1]))
      "/browse.php?u=#{encoded_url}&f=norefer"
    end
  end
  
  class PhpProxy < Proxy
    def valid?
      false
    end
  end
end
