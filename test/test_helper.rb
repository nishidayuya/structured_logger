require "test/unit"

require "stringio"
require "logger"

require "simplecov"
require "mocha/setup"

SimpleCov.start do
  add_filter "/test/"
end
