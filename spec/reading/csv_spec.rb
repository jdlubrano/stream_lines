# frozen_string_literal: true

require 'stream_lines/reading/csv'

RSpec.describe StreamLines::Reading::CSV do
  let(:url) { 'https://test.stream_lines.com' }
  let(:csv) { described_class.new(url) }

  it { expect(csv).to be_an(Enumerable) }

  describe '#each' do
    let(:csv_content) do
      <<~CSV
        foo,bar
        1,2
        3,4
      CSV
    end

    subject(:streamed_rows) do
      [].tap do |rows|
        csv.each { |row| rows << row }
      end
    end

    context 'when the request to fetch the CSV succeeds' do
      let(:csv) { described_class.new(url) }

      before do
        WebMock.stub_request(:get, url)
               .to_return(status: 200, body: csv_content)
      end

      context 'when the headers option is false' do
        it 'yields Arrays' do
          expect(streamed_rows).to all be_an(Array)
        end

        it 'returns the headers as the first row' do
          expect(streamed_rows.first).to eq(%w[foo bar])
        end

        it 'correctly yields the all of the data' do
          expect(streamed_rows).to eq([%w[foo bar],
                                       %w[1 2],
                                       %w[3 4]])
        end
      end

      context 'when the headers option is true' do
        let(:csv) { described_class.new(url, headers: true) }

        it 'yields CSV::Rows' do
          expect(streamed_rows).to all be_a(::CSV::Row)
        end

        it 'uses the first row as the headers' do
          expect(streamed_rows.first.headers).to eq(%w[foo bar])
        end

        it 'correctly yields all of the data' do
          expect(streamed_rows.map(&:to_h)).to eq([{ 'foo' => '1', 'bar' => '2' },
                                                   { 'foo' => '3', 'bar' => '4' }])
        end
      end

      context 'when the headers are provided as an array' do
        let(:csv) { described_class.new(url, headers: headers) }
        let(:headers) { %w[column_1 column_2] }

        it 'yields CSV::Rows' do
          expect(streamed_rows).to all be_a(::CSV::Row)
        end

        it 'yields the first row with the given headers' do
          expect(streamed_rows.first.to_h).to eq('column_1' => 'foo', 'column_2' => 'bar')
        end

        it 'correctly yields all of the data' do
          expect(streamed_rows.map(&:to_h)).to eq([{ 'column_1' => 'foo', 'column_2' => 'bar' },
                                                   { 'column_1' => '1', 'column_2' => '2' },
                                                   { 'column_1' => '3', 'column_2' => '4' }])
        end
      end

      context 'when converters are provided' do
        let(:csv) { described_class.new(url, converters: [:integer]) }

        it 'converts all of the data' do
          expect(streamed_rows).to eq([%w[foo bar],
                                       [1, 2],
                                       [3, 4]])
        end
      end
    end

    context 'when the request to fetch the CSV fails' do
      before do
        WebMock.stub_request(:get, url).to_return(status: 404)
      end

      it 'raises an error' do
        expect { streamed_rows }.to raise_error(StreamLines::Error)
      end
    end
  end
end
