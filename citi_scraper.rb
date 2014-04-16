# Name: citi_scraper.rb
# Description:
# Author: Bob Gardner
# Date: 4/14/14
# License: MIT

require 'mechanize'
require_relative 'bike_trip'

# Scrape the Citibike website
class CitiScraper
  def initialize
    @agent = Mechanize.new
  end

  def login(username, password)
    @agent.get('https://citibikenyc.com/login')
    @agent.page.forms[0]['subscriberUsername'] = username
    @agent.page.forms[0]['subscriberPassword'] = password
    @agent.page.forms[0].submit
    @agent.page.title
  end

  # Returns this month's trips. Returns nil if timeout.
  def trips
    return nil unless @agent.click('Trips').title['Trips']
    rows = Nokogiri::HTML(@agent.page.body).xpath('//table/tbody/tr')
    # reject rows with invalid date or durations < 2 minutes
    rows = rows.reject do |row|
      row.at_xpath('td[5]/text()').to_s.strip.empty? ||
              row.at_xpath('td[6]/text()').to_s.match(/(\d{1,2})m/)[1].to_i < 2
    end
    trips = rows.map do |row|
      trip = BikeTrip.new
      [
        [:id, 'td[1]/text()'],
        [:start_location, 'td[2]/text()'],
        [:start_time, 'td[3]/text()'],
        [:end_location, 'td[4]/text()'],
        [:end_time, 'td[5]/text()'],
        [:duration, 'td[6]/text()']
      ].each do |name, xpath|
        trip.send("#{name}=", row.at_xpath(xpath).to_s.strip)
      end
      trip
    end
    trips
  end
end
