require File.dirname(__FILE__) + '/helper'
require 'strawman/proxy'
require File.dirname(__FILE__) + '/mock_transport'

describe Strawman::GlypeProxy do
  before(:all) do
    @url = "http://proxy.com"
    @proxy = Strawman::GlypeProxy.new @url
    @proxy_check_url = "http://whatismyip.org"
  end

  before(:each) do
    EventMachine::MockHttpRequest.reset_registry!
    EventMachine::MockHttpRequest.reset_counts!
  end

  it "should be able to return a proxy url for any given url" do
    @proxy.proxy_url(@proxy_check_url).to_s.should == "http://proxy.com:80/browse.php?u=Oi8vd2hhdGlzbXlpcC5vcmc%3D%0A&f=norefer"
  end

  it "should return the proper referer to send" do
    @proxy.referer.should == @url
  end

  it "should be able to validate the given proxy" do
    EventMachine::MockHttpRequest.register_file(@proxy.proxy_url(@proxy_check_url),
                                                :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'proxy'))
    EventMachine.run {
      proxy_response = @proxy.validate(@proxy_check_url)
      proxy_response.callback {
        @proxy.should be_valid
        EventMachine.stop
      }
    }
  end
end
