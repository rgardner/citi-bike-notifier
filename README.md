# Citi Bike Notifier

_Messages you after returning a Citi Bike._

**This project is archived and is no longer active development.**

[The official Citi Bike apps][citi-bike-app] now provide this functionality
natively so this separate project is no longer needed.

[citi-bike-app]: https://www.citibikenyc.com/how-it-works/app

## Getting Started

```sh
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

```sh
nohup ruby driver.rb &
```
