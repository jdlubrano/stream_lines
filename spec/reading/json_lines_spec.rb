# frozen_string_literal: true

require 'stream_lines'

RSpec.describe StreamLines::Reading::JSONLines do
  let(:url) { 'https://test.stream_lines.com' }
  let(:json) { described_class.new(url) }

  it { expect(json).to be_an(Enumerable) }

  describe '#each' do
    let(:json_content) do
      <<~JSON
        { "foo": 1, "bar": "two" }
        { "foo": "three", "bar": 4 }
      JSON
    end

    let(:streamed_rows) do
      [].tap do |rows|
        json.each { |row| rows << row }
      end
    end

    context 'when the request to fetch the JSON lines succeeds' do
      before do
        WebMock.stub_request(:get, url)
               .to_return(status: 200, body: json_content)
      end

      it 'correctly yields all of the data' do
        expect(streamed_rows).to eq([{ 'foo' => 1, 'bar' => 'two' },
                                     { 'foo' => 'three', 'bar' => 4 }])
      end

      context 'when JSON parsing options are provided' do
        let(:json) { described_class.new(url, symbolize_names: true) }

        it 'uses the options when parsing the JSON' do
          expect(streamed_rows).to eq([{ foo: 1, bar: 'two' },
                                       { foo: 'three', bar: 4 }])
        end
      end

      context 'when the response contains invalid JSON' do
        let(:json_content) do
          <<~JSON
            { "foo": 1, "bar": "two" }
            { foo: "three", bar: 4 }
          JSON
        end

        it 'raises a JSON::ParserError' do
          expect { streamed_rows }.to raise_error(JSON::ParserError)
        end
      end
    end

    context 'when the request to fetch the JSON lines fails' do
      before do
        WebMock.stub_request(:get, url).to_return(status: 404)
      end

      it 'raises an error' do
        expect { streamed_rows }.to raise_error(StreamLines::Error)
      end
    end
  end
end
