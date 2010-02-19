require File.dirname(__FILE__) + '/helper'
require 'strawman/http_request'
require 'strawman/transport'
require File.dirname(__FILE__) + '/mock_transport'

describe Strawman::HttpRequest do
  before(:all) do
    @url = "http://example.com:80/"
    proxy_url = "http://proxy.com/"

    EventMachine::MockHttpRequest.register_file(@url, :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'twitter'))

    @proxy = mock("Proxy")
    @proxy.should_receive(:referer).and_return(proxy_url)
    @proxy.should_receive(:proxy_url).and_return {|u| u}
    deferrable = mock("Deferrable")
    deferrable.should_receive(:callback).and_return{|b| b.call(@proxy)}
    @proxy_list = mock("ProxyList")
    @proxy_list.should_receive(:proxy).and_return(deferrable)
  end

  it "should support HTTP get" do
    http_request = Strawman::HttpRequest.new @proxy_list, @url
    http_response = http_request.get
    EventMachine::MockHttpRequest.count(@url, :get).should == 1
  end
end
