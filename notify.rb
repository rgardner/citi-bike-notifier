# Name: notify.rb
# Description: Send ride summary to Citi Bike User.
# Author: Bob Gardner
# Updated: 4/15/14
# License: MIT

require 'twilio-ruby'
require 'yaml'

TWILIO_CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))

# Twilio Information
ACCOUNT_SID = TWILIO_CONFIG['twilio_account_sid']
AUTH_TOKEN = TWILIO_CONFIG['twilio_auth_token']
TWILIO_NUMBER = TWILIO_CONFIG['twilio_number']

# Cell number
MY_CELL_NUMBER = TWILIO_CONFIG['my_cell_number']

# Twilio helper class
class Notify
  SECS_PER_MIN = 60

  def self.notify_me(bike_trip)
    duration_in_minutes = bike_trip.duration / SECS_PER_MIN
    message = message(duration_in_minutes)

    send_message("#{message} You biked for #{bike_trip.pretty_duration}")
  end

  def self.message(duration_in_minutes)
    case duration_in_minutes
    when 0..3 then 'Whoa there Flash Gordon, be careful.'
    when 3..10 then 'Just a short ride.'
    when 10..30 then ''
    when 30..40 then 'Great ride!'
    when 40..45 then 'Too close for comfort, man!'
    else 'You had too much fun.'
    end
  end

  def self.send_message(message)
    client = Twilio::REST::Client.new(ACCOUNT_SID, AUTH_TOKEN)
    client.account.messages.create(
      from: TWILIO_NUMBER,
      to: MY_CELL_NUMBER,
      body: message
    )
  end

  private_class_method :message
end
