# twitter-notification-centre [![Build Status](https://travis-ci.org/rjlee/twitter-notification-centre.svg?branch=master)](https://travis-ci.org/rjlee/twitter-notification-centre)

Script to periodically run a twitter search and post notifications in Mac OS X notification centre.

![Exmaple in notification centre](https://raw.githubusercontent.com/rjlee/twitter-notification-centre/master/assets/example.png "")

It is designed to to run on your Mac and requires you to setup a twitter app that will search twitter using your credentials.  It uses the twitter gem https://github.com/sferik/twitter and instructions for setting up an app can be found in the README.

## Requires

* [Ruby](https://www.ruby-lang.org/en/)
* [Bundler](http://bundler.io/)

## Install

```
bundle install
ruby notify.rb --help

Usage: notify.rb [options]

        --search SEARCH              the search string to search twitter for
        --delay DELAY                the time in seconds between checking for updates
        --verbose                    displays verbose output
        --quiet                      output nothing on STDOUT
        --proxy PROXY                the proxy string to use, of the form protocol:://host:port
        --config CONFIG              the config file to use
        --consumer-key KEY           the consumer key for the app
        --consumer-secret SECRET     the consumer secret for the app
```

## Run

Modify the config file 'config.yaml.example' and save as 'config.yaml'.  Then to manage the server:

```
# Start the server and daemonize
ruby notify_server.rb start

# Stop the server
ruby notify_server.rb stop

# Run in interactive mode
ruby notify_server.rb run

# Supply command line args
ruby notify_server.rb run -- --verbose
```

## Adding as a launch daemon

Mac OS X supports running commands on login/periodically via launchd (see http://alvinalexander.com/mac-os-x/mac-osx-startup-crontab-launchd-jobs).  The following configuration will cause the launchd service to attempt to run the daemon once an hour when logged in.

To automate starting/running of the daemon:

```
cd /your/download/location/twitter-notification-centre
cp start_example.sh start.sh
chmod u+x start.sh
# Edit start.sh to include any required args/config 
mkdir ~/bin
ln -s start.sh ~/bin/twitter-notitier.sh
cp com.rjlee.twitter-notifier.plist $HOME/Library/LaunchAgents/
launchctl load $HOME/Library/LaunchAgents/com.rjlee.twitter-notifier.plist
```

To remove:

```
launchctl unload com.rjlee.twitter-notifier
rm $HOME/Library/LaunchAgents/com.rjlee.twitter-notifier.plist
```

## License

The software is made available under the Apache 2.0 license.  Any assets under the /assets directory are sourced from the web and as such their provenance is unknown.
