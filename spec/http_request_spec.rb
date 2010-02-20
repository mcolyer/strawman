require File.dirname(__FILE__) + '/helper'
require 'strawman/http_request'
require 'strawman/transport'
require File.dirname(__FILE__) + '/mock_transport'

describe Strawman::HttpRequest do
  before(:all) do
    @base_url = "http://example.com:80/"
    proxy_url = "http://proxy.com/"

    @proxy = mock("Proxy")
    @proxy.should_receive(:referer).and_return(proxy_url)
    @proxy.should_receive(:proxy_url).and_return {|u| u}
    deferrable = mock("Deferrable")
    deferrable.should_receive(:callback).and_return{|b| b.call(@proxy)}
    @proxy_list = mock("ProxyList")
    @proxy_list.should_receive(:proxy).and_return(deferrable)
  end

  before(:each) do
    EventMachine::MockHttpRequest.reset_registry!
    EventMachine::MockHttpRequest.reset_counts!
  end

  it "should support HTTP GET" do
    EventMachine::MockHttpRequest.register_file(@base_url, :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
    http_request = Strawman::HttpRequest.new @proxy_list, @base_url
    http_response = http_request.get
    EventMachine::MockHttpRequest.count(@base_url, :get).should == 1
  end

  it "should support HTTP POST" do
    EventMachine::MockHttpRequest.register_file(@base_url, :post,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
    http_request = Strawman::HttpRequest.new @proxy_list, @base_url
    http_response = http_request.post
    EventMachine::MockHttpRequest.count(@base_url, :post).should == 1
  end

  it "should support HTTP POST with parameters" do
    EventMachine::MockHttpRequest.register_file(@base_url, :post,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
    http_request = Strawman::HttpRequest.new @proxy_list, @base_url
    http_response = http_request.post :body => {:test => 1}
    EventMachine::MockHttpRequest.count(@base_url, :post).should == 1
  end
end
