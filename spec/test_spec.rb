require './twitternotifier.rb'

RSpec.describe TwitterNotifier do
	before(:each) do
		# Clear down any cmd line args supplied by rspec runner
  		ARGV.clear
	end
  it "accepts constructor options" do
  	tn = TwitterNotifier.new({  :delay => 1, 
  								:verbose => true, 
  								:quiet => true, 
  								:proxy => 'http://rjlee.net', 
  								:config => 'bobbins.yaml'})
  	expect(tn.options.delay).to eq(1)
  	expect(tn.options.verbose).to eq(true)
  	expect(tn.options.quiet).to eq(true)
  	expect(tn.options.proxy).to eq('http://rjlee.net')
  	expect(tn.options.config).to eq('bobbins.yaml')
  end
end
