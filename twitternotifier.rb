require 'rubygems'
require 'bundler/setup'

require 'optparse'
require 'ostruct'
require 'yaml'
require 'terminal-notifier'
require 'twitter'

class TwitterNotifier

  attr_reader :options

  def initialize(options = {})
    @options = OpenStruct.new
    # Set defaults
    @options.delay = 60
    @options.verbose = false
    @options.quiet = false
    @options.config = 'config.yaml'
    @options.proxy = ENV['HTTPS_PROXY'].nil? ? '' : ENV['HTTPS_PROXY']
    # Set any options supplied as constructor args
    options.keys.each { |key| @options[key.to_sym] = options[key] }
    # Set any options supplied as cmd line args
    parse
    # Set any options supplied in configuration file
    load_config
  end

  def run
    puts "Searching for:\n#{options.search}" unless @options.quiet
    client = connect
    recent_tweet_id = nil
    loop do
      soptions = recent_tweet_id.nil? ? {} : {:since_id => recent_tweet_id}
      puts "Searching with options:\n#{soptions}" if @options.verbose

      tweets = client.search(@options.search, soptions).take(100).collect
      tweets.each do |tweet|
        # Match either tweets that are new if we haven't seen any tweets before or tweets since the last most
        # recent tweet if we have seen tweets before.  This means it will send notifications for tweets
        # sent during being laptop being suspended and woken up
        if (recent_tweet_id.nil? && tweet.created_at >= Time.now-@options.delay) or (!recent_tweet_id.nil?)
          puts "#{tweet.user.screen_name}: #{tweet.text}" if @options.verbose
          TerminalNotifier.notify("#{tweet.user.screen_name}: #{tweet.text}", :title => 'Twitter Search', :appIcon => './assets/twitter.png', :sender => 'com.twitter.twitter-mac', :open => tweet.uri)
        end
      end
      recent_tweet_id = tweets.first.id if tweets.count > 0

      puts "Sleeping for #{@options.delay} secs" if @options.verbose
      sleep(@options.delay)
    end
  end


  private

  def parse
    opt_parser = OptionParser.new do |opts|
      opts.banner = "Usage: notify.rb [options]"
      opts.separator ""
      opts.on("--search SEARCH", "the search string to search twitter for") do |search|
        @options.search=search
      end
      opts.on("--delay DELAY", "the time in seconds between checking for updates") do |delay|
        @options.delay=delay.to_i
      end
      opts.on("--verbose", "displays verbose output") do |verbose|
        @options.verbose=true
      end
      opts.on("--quiet", "output nothing on STDOUT") do |quiet|
        @options.quiet
      end   
      opts.on("--proxy PROXY", "the proxy string to use, of the form protocol:://host:port") do |proxy|
        @options.proxy=proxy
      end 
      opts.on("--config CONFIG", "the config file to use") do |config|
        @options.config=config
      end
      opts.on("--consumer-key KEY", "the consumer key for the app") do |consumer_key|
        @options.consumer_key=consumer_key
      end
      opts.on("--consumer-secret SECRET", "the consumer secret for the app") do |consumer_secret|
        @options.consumer_secret=consumer_secret
      end
    end
    conf=opt_parser.parse!(ARGV)
  end

  def load_config
    if File.exist?(File.join(__dir__, @options.config))
      fileconf = {}
      fileconf = YAML::load_file(File.join(__dir__, @options.config))
      fileconf.keys.each do |key|
        @options[key.to_sym] = fileconf[key]
      end
      puts "Options loaded:\n#{@options}" if @options.verbose
    end   
  end

  def connect
    Twitter::REST::Client.new do |config|
      config.consumer_key        = @options.consumer_key
      config.consumer_secret     = @options.consumer_secret
      config.proxy = @options.proxy
    end
  end
end

if __FILE__==$0
  tn = TwitterNotifier.new
  tn.run
end



