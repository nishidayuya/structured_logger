# StructuredLogger

A structured logger with Ruby's Logger interface.

## Installation

Add this line to your application's Gemfile:

    gem 'structured_logger'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install structured_logger

## Usage

```ruby
t = Time.now; sleep(0.1)
l = StructuredLogger.new(STDOUT)

l.debug("processed request", started_at: t, elapsed_sec: Time.now - t, status: "ok")
#=> D, [2015-08-21T05:14:37.022621 #8310] DEBUG -- : processed request: started_at=2015-08-21 05:14:36 +0900 elapsed_sec=0.100156444 status="ok"

l.debug { ["processed request", started_at: t, elapsed_sec: Time.now - t, status: "ok"] }
#=> D, [2015-08-21T05:15:00.214480 #8416] DEBUG -- : processed request: started_at=2015-08-21 05:15:00 +0900 elapsed_sec=0.100193648 status="ok"
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
