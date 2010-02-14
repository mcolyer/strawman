module Strawman
  class ProxyList
    def set_sources(sources)
      multi = EventMachine::MultiRequest.new

      sources.each do |source|
        #multi.add(source.get)
      end
      multi.succeed
      multi
    end
  end
end
