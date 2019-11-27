# frozen_string_literal: true

require 'httparty'

require_relative 'error'

module StreamLines
  class Stream
    include Enumerable
    include HTTParty

    raise_on (400..599)

    def initialize(url)
      @url = url
      @buffer = StringIO.new
    end

    def each(&block)
      stream_lines(&block)
    rescue HTTParty::Error => e
      raise Error, "Failed to download #{url} with code: #{e.response.code}"
    end

    # def each_slice(n, &block); end

    private

    attr_reader :url

    def stream_lines(&block)
      self.class.get(url, stream_body: true) do |chunk|
        lines = extract_lines(chunk)
        lines.each { |line| block.call(line) }
      end

      @buffer.rewind
      block.call(@buffer.read) if @buffer.size.positive?
    end

    def extract_lines(chunk)
      lines = chunk.split($/, -1)

      if lines.length > 1
        @buffer.rewind
        lines.first.prepend(@buffer.read)
        @buffer.truncate(0)
      end

      @buffer << lines.pop
      lines
    end
  end
end
