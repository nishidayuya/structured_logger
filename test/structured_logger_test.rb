require "test_helper"

class StructuredLoggerTest < Test::Unit::TestCase
  setup do
    Time.stubs(:now).returns(NOW)
    @io = StringIO.new
    @l = StructuredLogger.new(@io)
  end

  sub_test_case("StructuredLogger for IO") do
    def test_add__message_with_optional_string_by_args
      t = Time.mktime(2015, 8, 16, 2, 13, 15)
      @l.add(Logger::DEBUG, "processed request",
             started_at: t,
             elapsed_sec: 0.03,
             status: "ok")
      assert_equal(DEBUG_HEADER +
                   " processed request:" +
                   " started_at=#{t.inspect}" +
                   " elapsed_sec=0.03" +
                   ' status="ok"' +
                   "\n",
                   @io.string)
    end

    def test_add__message_with_optional_string_by_block
      t = Time.mktime(2015, 8, 16, 2, 13, 15)
      @l.add(Logger::DEBUG) {
        [
          "processed request",
          started_at: t,
          elapsed_sec: 0.03,
          status: "ok",
        ]
      }
      assert_equal(DEBUG_HEADER +
                   " processed request:" +
                   " started_at=#{t.inspect}" +
                   " elapsed_sec=0.03" +
                   ' status="ok"' +
                   "\n",
                   @io.string)
    end

    def test_add__message_only_optional_string_by_args
      t = Time.mktime(2015, 8, 16, 2, 13, 15)
      @l.add(Logger::DEBUG,
             started_at: t,
             elapsed_sec: 0.03,
             status: "ok")
      assert_equal(DEBUG_HEADER +
                   " started_at=#{t.inspect}" +
                   " elapsed_sec=0.03" +
                   ' status="ok"' +
                   "\n",
                   @io.string)
    end

    def test_add__message_only_optional_string_by_block
      t = Time.mktime(2015, 8, 16, 2, 13, 15)
      @l.add(Logger::DEBUG) {
        {
          started_at: t,
          elapsed_sec: 0.03,
          status: "ok",
        }
      }
      assert_equal(DEBUG_HEADER +
                   " started_at=#{t.inspect}" +
                   " elapsed_sec=0.03" +
                   ' status="ok"' +
                   "\n",
                   @io.string)
    end
  end

  sub_test_case("log levels") do
    def test_debug
      @l.level = StructuredLogger::DEBUG
      log
      assert_equal(<<EOS, @io.string)
#{DEBUG_HEADER} added: l="debug"
#{INFO_HEADER} added: l="info"
#{WARN_HEADER} added: l="warn"
#{ERROR_HEADER} added: l="error"
#{FATAL_HEADER} added: l="fatal"
EOS
    end

    def test_info
      @l.level = StructuredLogger::INFO
      log
      assert_equal(<<EOS, @io.string)
#{INFO_HEADER} added: l="info"
#{WARN_HEADER} added: l="warn"
#{ERROR_HEADER} added: l="error"
#{FATAL_HEADER} added: l="fatal"
EOS
    end

    def test_warn
      @l.level = StructuredLogger::WARN
      log
      assert_equal(<<EOS, @io.string)
#{WARN_HEADER} added: l="warn"
#{ERROR_HEADER} added: l="error"
#{FATAL_HEADER} added: l="fatal"
EOS
    end

    def test_error
      @l.level = StructuredLogger::ERROR
      log
      assert_equal(<<EOS, @io.string)
#{ERROR_HEADER} added: l="error"
#{FATAL_HEADER} added: l="fatal"
EOS
    end

    def test_fatal
      @l.level = StructuredLogger::FATAL
      log
      assert_equal(<<EOS, @io.string)
#{FATAL_HEADER} added: l="fatal"
EOS
    end

    private

    def log
      %w(debug info warn error fatal).each do |n|
        @l.send(n, "added", l: n)
      end
    end
  end

  sub_test_case("backward compatibility with Logger") do
    setup do
      @logger_io = StringIO.new
      @logger = Logger.new(@logger_io)
    end

    def test_add__message_by_args
      args = [Logger::DEBUG, "Something happend."]
      @logger.add(*args)
      @l.add(*args)
      assert_equal(@logger_io.string, @io.string)
    end

    def test_add__message_by_block
      @logger.add(Logger::DEBUG) {"Something happend."}
      @l.add(Logger::DEBUG) {"Something happend."}
      assert_equal(@logger_io.string, @io.string)
    end

    def test_level__default_value
      assert_equal(@logger.level, @l.level)
    end

    %i(
      datetime_format
      level
    ).each do |method_name|
      test(method_name) do
        assert_equal(@logger.send(method_name), @l.send(method_name))
      end
    end
  end

  private

  NOW = Time.mktime(2015, 8, 16, 2, 26, 44, 123456)

  s_now = NOW.strftime("%FT%T.%6N")
  s = "%{short_severity_name}, [#{s_now} ##{Process.pid}] %<severity_name>5s -- :"
  DEBUG_HEADER = s % {short_severity_name: "D", severity_name: "DEBUG"}
  INFO_HEADER = s % {short_severity_name: "I", severity_name: "INFO"}
  WARN_HEADER = s % {short_severity_name: "W", severity_name: "WARN"}
  ERROR_HEADER = s % {short_severity_name: "E", severity_name: "ERROR"}
  FATAL_HEADER = s % {short_severity_name: "F", severity_name: "FATAL"}
end
