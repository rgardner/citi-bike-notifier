# Name: bike_trip.rb
# Description:
# Author: Bob Gardner
# Date: 4/15/14
# License: MIT

# Represents a Citi Bike trip
class BikeTrip
  DATE_FORMAT = '%m/%d/%y %l:%M:%S %p'       # citibike format as of 4/15/2013
  DURATION_REGEX = /(\d{1,2})m (\d{1,2})s/   # citibike format as of 4/15/2013
  SECS_PER_MIN = 60

  attr_accessor :id, :start_location, :start_time, :end_location, :end_time,
                :duration, :pretty_duration

  # Converts raw datetime string to DateTime object
  def start_time=(datetime)
    @start_time = Time.strptime(datetime, DATE_FORMAT)
  end

  def end_time=(datetime)
    @end_time = Time.strptime(datetime, DATE_FORMAT)
  end

  # Duration of trip in seconds
  def duration=(duration)
    if duration.is_a?(Integer)
      @duration = duration
    else
      minutes, seconds = DURATION_REGEX.match(duration).captures
      @duration = minutes.to_i * SECS_PER_MIN + seconds.to_i
      @pretty_duration = duration
    end
  end

  def to_csv
    start_time_formatted = @start_time.strftime(DATE_FORMAT)
    end_time_formatted = @end_time.strftime(DATE_FORMAT)
    "#{@id},#{@start_location},#{start_time_formatted},#{end_location}," \
    "#{end_time_formatted},#{@duration}"
  end
end
