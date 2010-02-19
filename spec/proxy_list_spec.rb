require File.dirname(__FILE__) + '/helper'
require 'strawman/proxy_list'
require 'strawman/source'
require 'strawman/proxy'
require 'strawman/transport'
require File.dirname(__FILE__) + '/mock_transport'

describe Strawman::ProxyList do
  before(:each) do
    EventMachine::MockHttpRequest.reset_registry!
    EventMachine::MockHttpRequest.reset_counts!
    EventMachine::MockHttpRequest.register_file('http://twitter.com:80/statuses/user_timeline/proxy_lists.json',
                                                :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'twitter'))
  end

  it "should verify sources with the given url and return a callback" do
    EventMachine.run {
      proxy_list = Strawman::ProxyList.new("http://whatismyip.org")
      proxy_response = proxy_list.set_sources([Strawman::TwitterSource.new("proxy_lists", false)])
      proxy_response.callback {
        proxy_list.proxies.size.should == 3
        EventMachine.stop
      }
    }
  end

  it "should verify sources as proxies are requested" do
    EventMachine.run {
      proxy_check_url = "http://whatismyip.org"
      proxy_list = Strawman::ProxyList.new(proxy_check_url)
      proxy_response = proxy_list.set_sources([Strawman::TwitterSource.new("proxy_lists", false)])
      proxy_response.callback {
        proxy = proxy_list.proxies.first
        proxy_list.proxies = [proxy]

        EventMachine::MockHttpRequest.register_file(proxy.proxy_url(proxy_check_url), :get,
                                                    File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
        proxy = proxy_list.proxy

        EventMachine::MockHttpRequest.count(proxy.proxy_url(proxy_check_url), :get).should == 1
        EventMachine.stop
      }
    }
  end
end
