module Strawman
  #
  # Represents a group of proxy sources
  #
  class ProxyList
    attr_reader :proxies

    #
    # [verification_url]  The url to use to verify that the proxy is valid. All
    #                     it needs to do is return an HTTP status of 200.
    #
    def initialize(verification_url)
      @proxies = []
      @verification_url = verification_url
    end

    #
    # Takes a list of sources and returns a deferrable which will complete once
    # all sources have been fetched and all proxies have been verified.
    #
    def set_sources(sources)
      sources_ready = EventMachine::MultiRequest.new
      proxies_ready = EventMachine::MultiRequest.new

      # Fetch all of the sources
      sources.each do |source|
        sources_ready.add(source)
      end

      # Verify all of the proxies
      sources_ready.callback do
        sources.each do |source|
          source.proxies.each do |proxy|
            proxies_ready.add(proxy.validate(@verification_url))
          end
        end
      end

      # Include proxies that are verified
      proxies_ready.callback do
        sources.each do |source|
          source.proxies.each do |proxy|
            @proxies << proxy if proxy.valid?
          end
        end
      end

      proxies_ready
    end

    #
    # Selects a random proxy from the list of available proxies
    #
    def proxy
      @proxies.choice
    end
  end
end
