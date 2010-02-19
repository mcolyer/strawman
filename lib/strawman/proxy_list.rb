module Strawman
  #
  # Represents a group of proxy sources
  #
  class ProxyList
    attr_accessor :proxies

    #
    # [verification_url]  The url to use to verify that the proxy is valid. All
    #                     it needs to do is return an HTTP status of 200.
    #
    def initialize(verification_url)
      @proxies = []
      @dead_proxies = []
      @verification_url = verification_url
    end

    #
    # Takes a list of sources and returns a deferrable which will complete once
    # all sources have been fetched.
    #
    def add_sources(sources)
      sources_ready = EventMachine::MultiRequest.new

      sources.each do |source|
        sources_ready.add(source)
      end

      sources_ready.callback do
        sources.each do |source|
          source.proxies.each do |proxy|
            @proxies << proxy unless @proxies.include? proxy
          end
        end
      end

      sources_ready
    end

    #
    # Selects a random proxy from the list of available proxies and verifies
    # it. If it isn't valid it keeps trying all available proxies before
    # returning nil.
    #
    def proxy
      proxy = @proxies.choice
      return nil unless proxy

      complete = false
      proxy.valid = false

      proxy_response = proxy.validate(@verification_url)
      proxy_response.callback { complete = true }
      proxy_response.errback do
        @proxies.remove(proxy)
        @dead_proxies.add(proxy)
        complete = true
      end

      while true
        break if complete
        sleep 0.1
      end

      if proxy.valid?
        proxy
      else
        self.proxy
      end
    end

    #
    # Saves all proxies that were loaded into this instance, including proxies
    # with errors.
    #
    def save(filepath)
      File.open(filepath, "w") do |f|
        f.write((@proxies + @dead_proxies).to_yaml)
      end
    end

    #
    # Loads all proxies from the given file
    #
    def load(filepath)
      @proxies = YAML.load(File.read(filepath))
    end
  end
end
