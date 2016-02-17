require 'rubygems'
#require 'bundler/setup'

require 'optparse'
require 'ostruct'
require 'yaml'
require 'terminal-notifier'
require 'twitter'

class TwitterNotifier

  DELAY=60
  VERBOSE=false
  QUIET=false

  attr_reader :options

  def initialize(options = {})
    options = options.dup
    options[:delay] ||= DELAY
    options[:verbose] ||= VERBOSE
    options[:quiet] ||= QUIET
    @options = OpenStruct.new(options)
  end

  def run
    puts "Searching for:\n#{options.search}" unless @options.quiet
    client = connect
    recent_tweet_id = nil
    while loop? do
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

  def loop?()
  	true
  end

  def connect
    Twitter::REST::Client.new do |config|
      config.consumer_key        = @options.consumer_key
      config.consumer_secret     = @options.consumer_secret
      config.proxy = @options.proxy
    end
  end
end
