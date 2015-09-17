#! /usr/bin/env ruby

require "tmpdir"
require "pathname"

def run(*args)
  if !system(*args)
    raise "failure #{args.inspect}"
  end
end

def setup
  top_source_path = Pathname(__FILE__).dirname.parent.expand_path
  Dir.chdir(Dir.mktmpdir)
  puts("run on #{Dir.pwd}")
  puts
  run("rails new blog")
  Dir.chdir("blog")
  open("Gemfile", "a") do |f|
    f.puts("gem 'structured_logger', path: '#{top_source_path}'")
  end
  run("bundle")
  File.write("config/initializers/structured_logger.rb", <<'EOS')
# Use StructuredLogger instead of Logger.
Rails.logger = ActiveSupport::TaggedLogging.new(StructuredLogger.new("log/#{Rails.env}.log"))
Rails.logger.formatter = ::Logger::Formatter.new
EOS
end

def check
  logs = File.read("log/development.log")

  puts
  puts("===== log/development.log =====")
  puts(logs)

  puts
  if /DEBUG -- : abc: foo="bar"$/.match(logs)
    puts("OK.")
    return 0
  else
    puts("NG!")
    return 1
  end
end

setup
run(*%w(bin/rails runner), <<EOS)
Rails.logger.debug("abc", foo: "bar")
EOS
exit(check)
