module Strawman
  #
  # Abstract class proxy used for either EventMachine::HttpRequests in
  # production or EventMachine::MockHttpRequest for testing.
  #
  class Transport
    def initialize(*args)
      @request = EventMachine::HttpRequest.new(*args)
    end
    def method_missing(method, *args)
      @request.send(method, *args)
    end
  end
end
