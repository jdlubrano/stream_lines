# frozen_string_literal: true

require 'json'
require 'stream_lines/reading/stream'

module StreamLines
  module Reading
    class JSONLines
      include Enumerable

      def initialize(url, encoding: Encoding.default_external, **json_options)
        @url = url
        @json_options = json_options
        @stream = Stream.new(url, encoding: encoding)
      end

      def each(&block)
        @stream.each { |line| block.call(parse_line(line)) }
      end

      private

      attr_reader :url

      def parse_line(line)
        JSON.parse(line, **@json_options)
      end
    end
  end
end
