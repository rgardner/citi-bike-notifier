#!/usr/bin/env ruby

# Name: driver.rb
# Description: Send ride summary to Citi Bike User.
# Author: Bob Gardner
# Updated: 4/15/14
# License: MIT

require_relative 'bike_trip'
require_relative 'citi_scraper'
require_relative 'notify'
require 'trollop'

CITIBIKE_CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))
SLEEP_DURATION = 600 # in seconds

def log(message)
  File.open('out.log', 'a') do |f|
    f.printf(message)
  end
end

opts = Trollop.options do
  banner 'Notify you after riding a Citi Bike'
  opt :dry_run, 'Do not send text notifications'
end

username = CITIBIKE_CONFIG['citibike_username']
password = CITIBIKE_CONFIG['citibike_password']
user = CitiScraper.new(username, password)

log "Successfully logged in to Citi Bike website\n"
unless opts[:dry_run]
  Notify.send_message('Welcome to Citi Bike Notifier! You are now setup to ' \
                      'receive text message notifications.')
end

loop do
  log "#{DateTime.now}: "
  trip = user.trips.first

  # check if ride completed in last SLEEP_DURATION secs
  if (Time.now - trip.end_time) < SLEEP_DURATION
    log 'Recent trip found! '
    Notify.notify_me(trip) unless opts[:dry_run]
  else
    log 'No recent trip found. '
  end

  log "Sleeping for #{SLEEP_DURATION} seconds.\n"
  sleep(SLEEP_DURATION)
end
