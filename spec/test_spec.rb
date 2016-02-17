require 'spec_helper'
require_relative '../lib/twitternotifier'

RSpec.describe TwitterNotifier do
  it "sets default values" do
    tn = TwitterNotifier.new()
    expect(tn.options.delay).to eq(TwitterNotifier::DELAY)
    expect(tn.options.verbose).to eq(TwitterNotifier::VERBOSE)
    expect(tn.options.quiet).to eq(TwitterNotifier::QUIET)
  end

  # http://stackoverflow.com/questions/13365366/rspec-unit-testing-a-method-which-has-a-infinite-loop
  # http://stackoverflow.com/questions/5717813/what-is-the-best-practice-when-it-comes-to-testing-infinite-loops/33348498#33348498
  #it "runs" do
  #	TwitterNotifier.expects(:loop).yields().then().returns()
  #	TwitterNotifier.new(delay: 1, search: "securitay", consumer_key: "", consumer_secret: "", verbose: true).run
  #end

end
