require "logger"
require "forwardable"

class StructuredLogger
  extend Forwardable
  include Logger::Severity
  autoload :VERSION, "structured_logger/version"

  attr_accessor :progname
  attr_accessor :formatter

  def self.severity_name(severity)
    return Logger::SEV_LABEL[severity] || "ANY"
  end

  def initialize(io)
    @logger = Logger.new(io)
    @progname = nil
    @formatter = nil
    @default_formatter = Logger::Formatter.new
    @arguments_formatter = ArgumentsFormatter.new
  end

  def_delegators :@logger,
    :close,
    :level, :level=,
    :debug?, :info?, :warn?, :error?, :fatal?

  def_delegators :@default_formatter, :datetime_format, :datetime_format=

  def debug(*args, &block)
    add(DEBUG, *args, &block)
  end

  def info(*args, &block)
    add(INFO, *args, &block)
  end

  def warn(*args, &block)
    add(WARN, *args, &block)
  end

  def error(*args, &block)
    add(ERROR, *args, &block)
  end

  def fatal(*args, &block)
    add(FATAL, *args, &block)
  end

  def add(severity, *args, &block)
    if level > severity
      return
    end
    block_result = block_given? ? yield : nil
    s_severity = format_severity(severity)
    time = Time.now
    message = @arguments_formatter.call(severity: s_severity,
                                        time: time,
                                        progname: @progname,
                                        args: args,
                                        block_result: block_result)
    s = (@formatter || @default_formatter).call(s_severity, time, @progname,
                                                message)
    @logger << s
  end

  private

  def format_severity(severity)
    return Logger::SEV_LABEL[severity] || "ANY"
  end

  class ArgumentsFormatter
    def call(severity: _, time: _, progname: _,
             args: args(), block_result: block_result())
      if block_result
        # {foo: "bar"} => [{foo: bar}]
        # ["msg", {foo: "bar"}] => ["msg", {foo: "bar"}]
        *args_and_block_result = block_result
      else
        args_and_block_result = args
      end
      return format_body(*args_and_block_result)
    end

    private

    def format_body(message = nil, **options)
      return [message, format_options(options)].compact.join(": ")
    end

    def format_options(options)
      if options.empty?
        return nil
      end
      return options.map { |key, value|
        "#{key}=#{value.inspect}"
      }.join(" ")
    end
  end
end
