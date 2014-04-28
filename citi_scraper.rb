# Name: citi_scraper.rb
# Description:
# Author: Bob Gardner
# Date: 4/28/14
# License: MIT

require 'mechanize'
require_relative 'bike_trip'

# Scrape the Citibike website
class CitiScraper
  LoginError = Class.new(StandardError)
  CitiBikeWebsiteError = Class.new(StandardError)

  LOGIN_URL = 'https://citibikenyc.com/login'
  TRIPS_URL = 'https://citibikenyc.com/member/trips'

  LOGIN_PAGE_TITLE = 'Login | Citi Bike'
  TRIPS_PAGE_TITLE = 'Trips | Citi Bike'

  MIN_TRIP_DURATION = 2 # in minutes

  attr_accessor :username, :password

  # initialize variables and login
  def initialize(username, password)
    @agent = Mechanize.new
    @username = username
    @password = password
    login
  end

  def login(username = @username, password = @password)
    @agent.get(LOGIN_URL)
    @agent.page.forms[0]['subscriberUsername'] = username
    @agent.page.forms[0]['subscriberPassword'] = password
    @agent.page.forms[0].submit
    if @agent.page.title == LOGIN_PAGE_TITLE
      fail LoginError, 'Invalid username or password.'
    end
    @password = password
    @username = username
  rescue Mechanize::ResponseCodeError => e
    handle_error(e)
    raise CitiBikeWebsiteError
  end
  end

  # Returns this month's trips.
  def trips
    @agent.get(TRIPS_URL)

    # If session expires, re-login to citibikenyc.com. The site will redirect
    # back to TRIPS_URL upon sign in (friendly forwarding)
    login unless @agent.page.title == TRIPS_PAGE_TITLE

    rows = Nokogiri::HTML(@agent.page.body).xpath('//table/tbody/tr')

    # Reject bike trips that are either in progress or have durations <
    #   MIN_TRIP_DURATION minutes.
    rows = rows.reject do |row|
      duration = row.at_xpath('td[6]/text()').to_s.match(/(\d{1,2})m/)
      !duration || (duration.captures[0].to_i < MIN_TRIP_DURATION)
    end
    rows.map { |row| row_to_trip(row) }
  end

  private

  # Handle Citi Bike Website errors (e.x. Net::HTTPGatewayTimeOut)
  def handle_error(error)
    puts error.message
    puts error.backtrace.join('\n')
  end

  # Convert HTML row into bike trip object
  def row_to_trip(row)
    trip = BikeTrip.new
    trip_attributes = [:id, :start_location, :start_time, :end_location,
                       :end_time, :duration]
    trip_attributes.each_with_index do |name, i|
      trip.send("#{name}=", row.at_xpath("td[#{i + 1}]/text()").to_s.strip)
    end
    trip
  end
end
