# This file is ported from ActiveSupport::TaggedLogging.
# https://github.com/rails/rails/blob/46b08da0eaccf1af4d69d01efa7f01e58ee3ca67/activesupport%2Flib%2Factive_support%2Ftagged_logging.rb

require "forwardable"

require "structured_logger"

class StructuredLogger
  module TaggedLogging
    module Formatter
      def call(severity, timestamp, message_or_other = nil, *pass_args)
        if String === message_or_other
          message = message_or_other
          additional_args = ["#{tags_text}#{message}"]
        else
          other = message_or_other
          additional_args = [tags_text, other]
        end
        super(severity, timestamp, *additional_args, *pass_args)
      end

      def tagged(*tags)
        new_tags = push_tags(*tags)
        yield(self)
      ensure
        pop_tags(new_tags.size)
      end

      def push_tags(*tags)
        return tags.flatten.select { |t|
          # We cannot use `blank?`.
          # Because we don't necessarily use ActiveSupport.
          t && !(BLANK_REGEXP === t)
        }.tap do |new_tags|
          current_tags.concat(new_tags)
        end
      end

      def pop_tags(size = 1)
        return current_tags.pop(size)
      end

      def clear_tags!
        return current_tags.clear
      end

      def current_tags
        return Thread.current[thread_key] ||= []
      end

      private

      BLANK_REGEXP = /\A[[:space:]]*\z/

      def thread_key
        return @thread_key ||=
          "structured_logger_tagged_logging_tags:#{object_id}".freeze
      end

      def tags_text
        tags = current_tags
        return (tags.any? ? tags.collect { |tag| "[#{tag}] " }.join : nil)
      end
    end

    extend Forwardable

    def self.new(logger)
      logger.formatter ||= StructuredLogger::Formatter.new
      logger.formatter.extend(StructuredLogger::TaggedLogging::Formatter)
      logger.extend(self)
      return logger
    end

    %i(push_tags pop_tags clear_tags!).each do |method_name|
      def_delegator :formatter, method_name, method_name
    end

    def tagged(*tags)
      formatter.tagged(*tags) {
        yield(self)
      }
    end

    def flush
      clear_tags!
      super if defined?(super)
    end
  end
end
