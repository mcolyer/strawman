module Strawman
  class HttpRequest
    def initialize(url)
      @request = EventMachine::HttpRequest.new(url)
    end
    
    def get
      http = @request.get
      http.callback {
        # TODO: Munge the return output
        #http.response = "asdf"
      }
      http
    end
  end
end
