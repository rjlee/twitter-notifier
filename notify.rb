require_relative 'lib/twitternotifier'

  def parse(options)
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
    opt_parser.parse!(ARGV)
    options
  end

  def load_config(options)
    if File.exist?(File.join(__dir__, options.config))
      fileconf = {}
      fileconf = YAML::load_file(File.join(__dir__, options.config))
      fileconf.keys.each do |key|
        options[key.to_sym] = fileconf[key]
      end
    end  
    options 
  end

options = OpenStruct.new
# Set defaults
options.config = 'config.yaml'
options.proxy = ENV['HTTPS_PROXY'].nil? ? '' : ENV['HTTPS_PROXY']
# Set options from config
options = load_config(options)
# Set options from cmd line
options = parse(options)

tn = TwitterNotifier.new(options.to_h)
tn.run
