# StructuredLogger

A structured logger with Ruby's Logger interface.

[![License X11](https://img.shields.io/badge/license-X11-brightgreen.svg)](https://raw.githubusercontent.com/nishidayuya/structured_logger/master/LICENSE.txt)
[![Gem Version](https://badge.fury.io/rb/structured_logger.svg)](http://badge.fury.io/rb/structured_logger)
[![Dependency Status](https://gemnasium.com/nishidayuya/structured_logger.svg)](https://gemnasium.com/nishidayuya/structured_logger)
[![Build Status](https://travis-ci.org/nishidayuya/structured_logger.svg?branch=master)](https://travis-ci.org/nishidayuya/structured_logger)
[![Code Climate](https://codeclimate.com/github/nishidayuya/structured_logger/badges/gpa.svg)](https://codeclimate.com/github/nishidayuya/structured_logger)

## Installation

Add this line to your application's Gemfile:

    gem 'structured_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install structured_logger

## Usage

We can write log with parameters.

```ruby
t = Time.now; sleep(0.1)
l = StructuredLogger.new(STDOUT)

l.debug("processed request", started_at: t, elapsed_sec: Time.now - t, status: "ok")
#=> D, [2015-08-21T05:14:37.022621 #8310] DEBUG -- : processed request: started_at=2015-08-21 05:14:36 +0900 elapsed_sec=0.100156444 status="ok"

l.debug { ["processed request", started_at: t, elapsed_sec: Time.now - t, status: "ok"] }
#=> D, [2015-08-21T05:15:00.214480 #8416] DEBUG -- : processed request: started_at=2015-08-21 05:15:00 +0900 elapsed_sec=0.100193648 status="ok"
```

`StructuredLogger` instance methods have Ruby's `Logger` interface. So, we can replace Ruby's `Logger` to `StructuredLogger`.

```ruby
l = Logger.new(STDOUT)
l.error("Something happend")
#=> E, [2015-08-25T06:43:18.244950 #23623] ERROR -- : Something happend

l = StructuredLogger.new(STDOUT)
l.error("Something happend")
#=> E, [2015-08-25T06:43:47.798889 #23623] ERROR -- : Something happend
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake false` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/nishidayuya/structured_logger.
