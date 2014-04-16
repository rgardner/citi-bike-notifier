#!/usr/bin/env ruby

# Name: driver.rb
# Description: Send ride summary to Citi Bike User.
# Author: Bob Gardner
# Updated: 4/15/14
# License: MIT

require_relative 'bike_trip'
require_relative 'citi_scraper'
require_relative 'notify'

$stdout.reopen('out.log', 'w')
$stderr.reopen('err.log', 'w')

LOGIN_SUCCESS = 'Welcome To Citi Bike!'
CITIBIKE_CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))
SLEEP_DURATION = 300 # in seconds

user = CitiScraper.new
username = CITIBIKE_CONFIG['citibike_username']
password = CITIBIKE_CONFIG['citibike_password']

unless user.login(username, password) == LOGIN_SUCCESS
  fail 'Incorrect username or password'
end

puts 'Successfully logged in to Citi Bike website'

loop do
  print "#{DateTime.now}: "
  trip = user.trips.first
  unless trip
    user.login(username, password)
    trip = user.trips.first
  end

  # check if ride completed in last SLEEP_DURATION secs
  if (DateTime.now.to_time.to_i - trip.end_time.to_time.to_i) < SLEEP_DURATION
    print 'Recent trip found! '
    notify_me
  else
    print 'No recent trip found. '
  end

  puts "Sleeping for #{SLEEP_DURATION} seconds"
  sleep(SLEEP_DURATION)
end
