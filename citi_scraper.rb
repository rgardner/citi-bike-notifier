# Name: citi_scraper.rb
# Description:
# Author: Bob Gardner
# Date: 4/14/14
# License: MIT

require 'mechanize'
require_relative 'bike_trip'

# Scrape the Citibike website
class CitiScraper
  LoginError = Class.new(StandardError)

  LOGIN_URL = 'https://citibikenyc.com/login'
  TRIPS_URL = 'https://citibikenyc.com/member/trips'
  LOGIN_SUCCESS = 'Welcome To Citi Bike!'
  TRIPS_SUCCESS = 'Trips | Citi Bike'

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
    unless @agent.page.title == LOGIN_SUCCESS
      fail LoginError, 'Invalid username or password.'
    end
    @password = password
    @username = username
  end

  # Returns this month's trips.
  def trips
    @agent.get(TRIPS_URL)
    unless @agent.page.title == TRIPS_SUCCESS
      login
      @agent.get(TRIPS_URL)
    end
    rows = Nokogiri::HTML(@agent.page.body).xpath('//table/tbody/tr')

    # reject rows with durations < 2 minutes
    rows = rows.reject do |row|
      row.at_xpath('td[6]/text()').to_s.match(/(\d{1,2})m/)[1].to_i < 2
    end
    rows.map { |row| row_to_trip(row) }
  end

  private

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
