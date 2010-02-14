module Strawman
  class ProxyList
    def initialize
      @proxies = []
    end

    def set_sources(sources)
      sources_ready = EventMachine::MultiRequest.new

      sources.each do |source|
        sources_ready.add(source)
      end

      proxies_ready = EventMachine::MultiRequest.new
      sources_ready.callback do
        sources.each do |source|
          source.proxies.each do |proxy|
            proxies_ready.add(proxy.validate)
          end
        end
      end

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
