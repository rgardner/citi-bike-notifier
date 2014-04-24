# citi-bike-notifier

Messages you after returning a Citi Bike.

## Getting Started

```
git clone https://github.com/rgardner/citi-bike-notifier.git
cd citi-bike-notifier
bundle install
cp config.yml.example config.yml
```

In config.yml:

  1. Fill in your [Citi Bike](https://citibikenyc.com) username and password
  2. Fill in your [Twilio](https://www.twilio.com) account sid, auth token, phone
      number
  3. Add your phone number (the number you want to send messages to)

To run in background:

```
nohup ruby driver.rb &
```
