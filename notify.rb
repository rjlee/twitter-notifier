require 'rubygems'
require 'bundler/setup'

require 'optparse'
require 'ostruct'
require 'terminal-notifier'
require 'twitter'
require 'yaml'
require 'pp'

options = OpenStruct.new
options.delay = 60
options.verbose = false
options.quiet = false
options.proxy = ''
options.config = 'config.yaml'
options.proxy = ENV['HTTPS_PROXY']

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
  opts.on("--quiet", "output nothing on STDOUT") do |quiet|
    options.quiet
  end   
  opts.on("--proxy PROXY", "the proxy string to use, of the form protocol:://host:port") do |proxy|
    options.proxy=proxy
  end 
  opts.on("--config CONFIG", "the config file to use") do |config|
    options.config=config
  end
  opts.on("--consumer-key KEY", "the consumer key for the app") do |consumer_key|
    options.consumer_key=consumer_key
  end
  opts.on("--consumer-secret SECRET", "the consumer secret for the app") do |consumer_secret|
    options.consumer_secret=consumer_secret
  end
end
conf=opt_parser.parse!(ARGV)

if File.exist?(File.join(__dir__, options.config))
  fileconf = {}
  fileconf = YAML::load_file(File.join(__dir__, options.config))
  fileconf.keys.each do |key|
    options[key.to_sym] = fileconf[key]
  end
  if options.verbose
    puts "Options loaded:"
    pp options
  end
end

client = Twitter::REST::Client.new do |config|
  config.consumer_key        = options.consumer_key
  config.consumer_secret     = options.consumer_secret
  config.proxy = options.proxy
end

unless options.quiet
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

