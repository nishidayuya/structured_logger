if ENV["CODECLIMATE_REPO_TOKEN"]
  require "codeclimate-test-reporter"
  CodeClimate::TestReporter.start
end

require "test/unit"

require "stringio"
require "logger"

require "mocha/setup"
