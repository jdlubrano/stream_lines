# frozen_string_literal: true

require 'httparty'

require 'stream_lines/error'

module StreamLines
  module Reading
    class Stream
      include Enumerable
      include HTTParty

      raise_on 400..599

      def initialize(url, encoding: 'UTF-8')
        @url = url
        @encoding = encoding
        @buffer = String.new(encoding: @encoding)
      end

      def each(&block)
        stream_lines(&block)
      rescue HTTParty::Error => e
        raise Error, "Failed to download #{url} with code: #{e.response.code}"
      end

      private

      attr_reader :url

      def stream_lines(&block)
        self.class.get(url, stream_body: true) do |chunk|
          lines = extract_lines(chunk)
          lines.each { |line| block.call(line) }
        end

        @buffer
        block.call(@buffer) if @buffer.size.positive?
      end

      def extract_lines(chunk)
        encoded_chunk = chunk.to_s.dup.force_encoding(@encoding)
        lines = encoded_chunk.split($INPUT_RECORD_SEPARATOR, -1)

        if lines.length > 1
          lines.first.prepend(@buffer)
          @buffer = String.new(encoding: @encoding)
        end

        @buffer << lines.pop.to_s
        lines
      end
    end
  end
end
