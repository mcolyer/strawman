require File.dirname(__FILE__) + '/helper'
require 'strawman/source'
require 'strawman/proxy'
require File.dirname(__FILE__) + '/mock_transport'

describe Strawman::TwitterSource do
  before(:each) do
    EventMachine::MockHttpRequest.reset_registry!
    EventMachine::MockHttpRequest.reset_counts!
  end

  it "should fetch the data from a twitter user and parse the results" do
    twitter_url = 'http://twitter.com:80/statuses/user_timeline/proxy_lists.json'
    EventMachine::MockHttpRequest.register_file(twitter_url, :get,
                                                File.join(File.dirname(__FILE__), 'fixtures', 'twitter'))
    EventMachine.run {
      source = Strawman::TwitterSource.new("proxy_lists", false)
      source.callback {
        source.proxies.size.should == 3
        EventMachine.stop
      }
    }

  end
end
