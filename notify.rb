require 'rubygems'
require 'bundler/setup'

require 'optparse'
require 'ostruct'
require 'terminal-notifier'
require 'twitter'

options = OpenStruct.new
options.delay = 60
options.verbose= false

opt_parser = OptionParser.new do |opts|
  opts.banner = "Usage: notify.rb [options]"
  opts.separator ""
  opts.on("--search SEARCH", "the search string to search twitter for") do |search|
    options.search=search
  end
  opts.on("--delay DELAY", "the time in seconds between checking for updates") do |delay|
    options.delay=delay.to_i
  end
  opts.on("--verbose", "displays verbose output") do |verbose|
    options.verbose=true
  end
  opts.on("--consumer-key KEY", "the consumer key for the app") do |consumer_key|
    options.consumer_key=consumer_key
  end
  opts.on("--consumer-secret SECRET", "the consumer secret for the app") do |consumer_secret|
    options.consumer_secret=consumer_secret
  end
  opts.on("--access-token TOKEN", "the access token for the user") do |access_token|
    options.access_token=access_token
  end
  opts.on("--access-token-secret SECRET", "the access token secret for the user") do |access_token_secret|
    options.access_token_secret=access_token_secret
  end
end
opt_parser.parse!(ARGV)

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = options.consumer_key
  config.consumer_secret     = options.consumer_secret
  config.access_token        = options.access_token
  config.access_token_secret = options.access_token_secret
end

if options.verbose
  puts "Searching for:"
  puts options.search
end

loop do
  client.search(options.search).take(10).collect do |tweet|
    if tweet.created_at >= Time.now-options.delay
      puts "#{tweet.user.screen_name}: #{tweet.text}" if options.verbose
      TerminalNotifier.notify("#{tweet.user.screen_name}: #{tweet.text}", :title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => tweet.uri)
    end
  end
  puts "Sleeping for #{options.delay} secs" if options.verbose
  sleep(options.delay)
end

