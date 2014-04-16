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
CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))
SLEEP_DURATION = 300 # in seconds

user = CitiScraper.new
username = CONFIG['citibike_username']
password = CONFIG['citibike_password']

unless user.login(username, password) == LOGIN_SUCCESS
  fail 'Incorrect username or password'
end

puts 'Successfully logged in to Citi Bike website'

loop do
  trip = user.trips.head
  unless trip
    user.login(username, password)
    trip = user.trips.head
  end

  # check if ride completed in last SLEEP_DURATION secs
  if (DateTime.now.to_time.to_i - trip.end_time.to_time.to_i) < SLEEP_DURATION
    notify_me
  end
  sleep(SLEEP_DURATION)
end
