module Strawman
  class Transport
    def initialize(*args)
      @request = EventMachine::MockHttpRequest.new(*args)
      EventMachine::MockHttpRequest.pass_through_requests = false
    end
    def method_missing(method, *args)
      @request.send(method, *args)
    end
  end
end
