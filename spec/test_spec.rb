require 'spec_helper'
require_relative '../lib/twitternotifier'

RSpec.describe TwitterNotifier do
  it "sets default values" do
    tn = TwitterNotifier.new()
    expect(tn.options.delay).to eq(TwitterNotifier::DELAY)
    expect(tn.options.verbose).to eq(TwitterNotifier::VERBOSE)
    expect(tn.options.quiet).to eq(TwitterNotifier::QUIET)
  end

  it "runs" do
    # Setup stub tweet data
    tweet3 = stub(id: 3, created_at: Time.now, user: stub(screen_name: 'rjlee'), text: 'boo 3', uri: 'http://rjlee.net')
    tweet2 = stub(id: 2, created_at: Time.now+60, user: stub(screen_name: 'rjlee'), text: 'boo 2', uri: 'http://rjlee.net')
    tweet1 = stub(id: 1, created_at: Time.now+120, user: stub(screen_name: 'rjlee'), text: 'boo 1', uri: 'http://rjlee.net')
    # This sets the expectation that the first two tweets will be notified in the first loop and then the third tweet will be notified in the second loop
    client = stub
    client.stubs(:search).returns([tweet2, tweet1]).returns([tweet3]).returns([tweet2, tweet1]).returns([tweet3])
    TerminalNotifier.expects(:notify).with('rjlee: boo 1', {:title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => 'http://rjlee.net'})
    TerminalNotifier.expects(:notify).with('rjlee: boo 2', {:title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => 'http://rjlee.net'})
    TerminalNotifier.expects(:notify).with('rjlee: boo 3', {:title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => 'http://rjlee.net'})
    TerminalNotifier.expects(:notify).with('rjlee: boo 1', {:title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => 'http://rjlee.net'})
    TerminalNotifier.expects(:notify).with('rjlee: boo 2', {:title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => 'http://rjlee.net'})
    TerminalNotifier.expects(:notify).with('rjlee: boo 3', {:title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => 'http://rjlee.net'})

    tn = TwitterNotifier.new(delay: 1, search: ["securitay", "securitay"], verbose: false, quiet: true)
    tn.stubs(:connect).returns(client)
    # This causes the loop to run twice before exiting, allowing testing of recent tweet caching
    tn.stubs(:loop?).returns(true).returns(true).returns(false)

    tn.run
  end

end
