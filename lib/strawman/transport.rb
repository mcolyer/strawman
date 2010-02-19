module Strawman
  class Transport
    def initialize(*args)
      @request = EventMachine::HttpRequest.new(*args)
    end
    def method_missing(method, *args)
      @request.send(method, *args)
    end
  end
end
