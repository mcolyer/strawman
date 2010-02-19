module Strawman
  class ProxyList
    attr_reader :proxies

    def initialize(verification_url)
      @proxies = []
      @verification_url = verification_url
    end

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

    def proxy
      @proxies.choice
    end
  end
end
