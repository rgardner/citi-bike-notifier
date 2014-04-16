# Name: notify.rb
# Description: Send ride summary to Citi Bike User.
# Author: Bob Gardner
# Updated: 4/15/14
# License: MIT

require 'twilio-ruby'

CONFIG = YAML.load_file(File.join(__dir__, 'config.yml'))

# Twilio Information
ACCOUNT_SID = CONFIG['twilio_account_sid']
AUTH_TOKEN = CONFIG['twilio_auth_token']
TWILIO_NUMBER = CONFIG['twilio_number']

# Cell number
MY_CELL_NUMBER = CONFIG['my_cell_number']

def notify_me(bike_trip)
  message =
    case bike_trip.duration
    when 0..3 then 'Whoa there Flash Gordon, be careful.'
    when 3..10 then 'Just a short ride.'
    when 10..30 then ''
    when 30..40 then 'Great ride!'
    when 40..45 then 'Too close for comfort, man!'
    else 'You had too much fun.'
    end

  send_message("#{message} You biked for #{bike_trip.pretty_duration}")
end

def send_message(message)
  client = Twilio::Rest::Client.new(ACCOUNT_SID, AUTH_TOKEN)
  client.acount.messages.create(
    from: TWILIO_NUMBER,
    to: MY_CELL_NUMBER,
    body: message
  )
end
