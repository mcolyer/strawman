module Strawman
  #
  # The general proxy class, which contains functions not specific to any type
  # of proxy.
  #
  class Proxy
    attr_reader :root_url
    attr_writer :valid

    def initialize(url)
      @root_url = url
      @valid = false
    end

    #
    # Returns the the referer to use when making the proxied request.
    #
    def referer
      @root_url
    end

    #
    # Returns the url to fetch the given url through this proxy.
    #
    def proxy_url(url)
      uri = URI.join @root_url, proxy_path(url)
      "#{uri.scheme}://#{uri.host}:#{uri.port}#{uri.path}?#{uri.query}"
    end

    #
    # Used to determine whether this proxy is valid. This must be called from
    # within the callback of the validate deferable.
    #
    def valid?
      @valid
    end

    def ==(other)
      self.class == other.class && self.root_url == other.root_url
    end

  protected
    def proxy_path(url)
      raise NotImplementedError
    end
  end

  #
  # An implementation of the Proxy class which is specific to Glype proxies.
  # See: http://www.glype.com/ for more details.
  #
  class GlypeProxy < Proxy
    #
    # Verifies whether this proxy is currently functional. Returns a deferable.
    #
    def validate(verification_url)
      @valid = false

      # FIXME: This only validate proxies that don't require a unique session
      # cookie which is retrieved by going to the root page and looking for the
      # s cookie.
      url = proxy_url(verification_url)
      http = Transport.new(url).get :head => {'referer' => @root_url}
      http.callback {
        @valid = true if http.response_header.status == 200
      }

      http
    end

    def to_s
      "<GlypeProxy #{@root_url}>"
    end

protected
    def proxy_path(url)
      encoded_url = CGI.escape(Base64.encode64(url[4..-1]))
      "/browse.php?b=4&u=#{encoded_url}"
    end
  end
end
