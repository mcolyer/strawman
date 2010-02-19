require File.dirname(__FILE__) + '/helper'
require 'strawman/http_request'
require 'strawman/transport'

describe Strawman::HttpRequest do
  before(:all) do
    @url = "http://example.com"
    proxy_url = "http://proxy.com"

    @em_callback = EventMachine::DefaultDeferrable.new
    @em_callback.succeed
    @em_request = mock("HttpRequest")
    @em_request.should_receive(:get).with(:head => {"referer" => proxy_url}).and_return(@em_callback)
    Strawman::Transport.should_receive(:new).with(@url).and_return(@em_request)

    @proxy = mock("Proxy")
    @proxy.should_receive(:referer).and_return(proxy_url)
    @proxy.should_receive(:proxy_url).and_return {|u| u}
    @proxy_list = mock("ProxyList")
    @proxy_list.should_receive(:proxy).and_return(@proxy)
  end

  it "should support HTTP get" do
    http_request = Strawman::HttpRequest.new @proxy_list, @url
    http_response = http_request.get
    http_response.should == @em_callback
  end
end
