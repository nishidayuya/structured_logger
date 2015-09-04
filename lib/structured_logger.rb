require "logger"
require "forwardable"

class StructuredLogger
  extend Forwardable
  include Logger::Severity
  autoload :VERSION, "structured_logger/version"

  attr_accessor :formatter

  def self.severity_name(severity)
    return Logger::SEV_LABEL[severity] || "ANY"
  end

  def initialize(io)
    @logger = Logger.new(io)
    @formatter = nil
    @default_formatter = Formatter.new
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
    if block_given?
      *args = yield
    end
    s = (@formatter || @default_formatter).call(severity, Time.now, *args)
    @logger << s
  end

  # Default formatter for StructuredLogger.
  class Formatter
    attr_accessor :datetime_format

    def initialize
      @datetime_format = nil
    end

    def call(severity, time, message = nil, **options)
      severity_name = StructuredLogger.severity_name(severity)
      return FORMAT % {
        short_severity_name: severity_name[0, 1],
        datetime: format_datetime(time),
        pid: Process.pid,
        severity_name: severity_name,
        program_name: "",
        message: format_message(message, **options),
      }
    end

    private

    FORMAT = "%{short_severity_name}, [%{datetime} #%{pid}] %<severity_name>5s -- %{program_name}: %{message}\n"

    def format_datetime(time)
      time.strftime(@datetime_format || "%Y-%m-%dT%H:%M:%S.%6N".freeze)
    end

    def format_message(message = nil, **options)
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
