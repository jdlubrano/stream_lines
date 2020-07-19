# frozen_string_literal: true

require 'httparty'

require 'stream_lines/error'

module StreamLines
  module Reading
    class Stream
      include Enumerable
      include HTTParty

      raise_on 400..599

      def initialize(url, encoding: Encoding.default_external)
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

        block.call(@buffer) if @buffer.size.positive?
      end

      def extract_lines(chunk)
        encoded_chunk = @buffer + chunk.to_s.dup.force_encoding(@encoding)
        lines = split_lines(encoded_chunk)
        @buffer = String.new(encoding: @encoding)
        @buffer << lines.pop.to_s

        lines
      end

      def split_lines(encoded_chunk)
        lines = encoded_chunk.split($INPUT_RECORD_SEPARATOR, -1)
      rescue ArgumentError => e
        raise e unless /invalid byte sequence/.match?(e.message)

        # NOTE: (jdlubrano)
        # The last byte in the chunk is most likely a part of a multibyte
        # character that, on its own, is an invalid byte sequence.  So, we
        # want to split the lines containing all valid bytes and make the
        # trailing bytes the last line.  The last line eventually gets added
        # to the buffer, prepended to the next chunk, and, hopefully, restores
        # a valid byte sequence.
        last_newline_index = encoded_chunk.rindex($INPUT_RECORD_SEPARATOR)
        return [encoded_chunk] if last_newline_index.nil?

        valid_lines = encoded_chunk[0...last_newline_index].split($INPUT_RECORD_SEPARATOR, -1)
        valid_lines + [encoded_chunk[(last_newline_index + 1)..-1]].compact
      end
    end
  end
end
