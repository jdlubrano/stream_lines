# frozen_string_literal: true

require 'csv'
require 'stream_lines/error'
require 'stream_lines/reading/stream'

module StreamLines
  module Reading
    class CSV
      # NOTE: (jdlubrano)
      # I suspect that these options are not used terribly frequently, and each
      # would require additional logic in the #each method.  Rather than
      # attempting to implement sensible solutions for these options, I am
      # choosing to explicitly ignore them until there is enough outcry to
      # support them.
      IGNORED_CSV_OPTIONS = %i[
        return_headers
        header_converters
        skip_lines
      ].freeze

      include Enumerable

      def initialize(url, **csv_options)
        @url = url
        @csv_options = accepted_csv_options(csv_options)
        @stream = Stream.new(url)
      end

      def each(&block)
        @stream.each_with_index do |line, i|
          next assign_first_row_headers(line) if i.zero? && first_row_headers?

          block.call(::CSV.parse_line(line, **@csv_options))
        end
      end

      private

      attr_reader :url

      def first_row_headers?
        @csv_options[:headers] == true
      end

      def assign_first_row_headers(first_line)
        header_row = ::CSV.parse_line(first_line)
        @csv_options[:headers] = header_row
      end

      def accepted_csv_options(csv_options)
        csv_options.transform_keys(&:to_sym)
                   .delete_if { |key, _value| IGNORED_CSV_OPTIONS.include?(key) }
      end
    end
  end
end
