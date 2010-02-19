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
    EventMachine::MockHttpRequest.register_file('http://surfproxy.org:80/browse.php?u=Oi8vd2hhdGlzbXlpcC5vcmc%3D%0A&f=norefer',
                                                :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
    EventMachine::MockHttpRequest.register_file('http://balikavadhuonline.com:80/browse.php?u=Oi8vd2hhdGlzbXlpcC5vcmc%3D%0A&f=norefer',
                                                :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
    EventMachine::MockHttpRequest.register_file('http://love2bunk.com:80/browse.php?u=Oi8vd2hhdGlzbXlpcC5vcmc%3D%0A&f=norefer',
                                                :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
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
end
