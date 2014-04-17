#!/usr/bin/env ruby

# Name: driver.rb
# Description: Send ride summary to Citi Bike User.
# Author: Bob Gardner
# Updated: 4/15/14
# License: MIT

require_relative 'bike_trip'
require_relative 'citi_scraper'
require_relative 'notify'

LOGIN_SUCCESS = 'Welcome To Citi Bike!'
CITIBIKE_CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))
SLEEP_DURATION = 600 # in seconds

def log(message)
  File.open('out.log', 'a') do |f|
    f.printf(message)
  end
end

user = CitiScraper.new
username = CITIBIKE_CONFIG['citibike_username']
password = CITIBIKE_CONFIG['citibike_password']

unless user.login(username, password) == LOGIN_SUCCESS
  fail 'Incorrect username or password'
end

log "Successfully logged in to Citi Bike website\n"
send_message('Welcome to Citi Bike Notifier! You are now setup to receive a ' \
             'message after returning a Citi Bike.')

loop do
  log "#{DateTime.now}: "
  trips = user.trips
  unless trips
    user.login(username, password)
    trips = user.trips
  end
  trip = trips.first

  # check if ride completed in last SLEEP_DURATION secs
  if (DateTime.now.to_time.to_i - trip.end_time.to_time.to_i) < SLEEP_DURATION
    log 'Recent trip found! '
    notify_me(trip)
  else
    log 'No recent trip found. '
  end

  log "Sleeping for #{SLEEP_DURATION} seconds.\n"
  sleep(SLEEP_DURATION)
end
