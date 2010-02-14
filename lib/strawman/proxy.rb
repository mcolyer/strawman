module Strawman
  class Proxy
  end

  class GlypeProxy < Proxy
    def initialize(url)
    end

    def valid?
      http = EventMachine::HttpRequest().get
      http.callback {

      }
    end
  end
  
  class PhpProxy < Proxy
    def valid?
      false
    end
  end
end
