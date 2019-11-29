# frozen_string_literal: true

require 'rack'
require 'stream_lines/reading/stream'

RSpec.describe StreamLines::Reading::Stream do

  let(:url) { 'https://test.stream_lines.com' }
  let(:stream) { described_class.new(url) }

  it { expect(stream).to be_an(Enumerable) }

  describe '#each' do

    subject(:streamed_lines) do
      [].tap do |lines|
        stream.each { |line| lines << line }
      end
    end

    context 'when the content is multiple lines less than the chunk size' do

      before do
        allow(described_class).to receive(:get).and_yield("foo\nbar")
      end

      it 'calls the block with each line' do
        expect(streamed_lines).to eq(['foo', 'bar'])
      end
    end

    context 'when the content is all 1 line, but multiple chunks' do

      before do
        allow(described_class).to receive(:get).and_yield('a' * 100).and_yield('a' * 100)
      end

      it 'calls the block with the 1 line' do
        expect(streamed_lines).to eq(['a' * 200])
      end
    end

    context 'when a chunk ends with a newline' do

      before do
        allow(described_class)
          .to receive(:get)
          .and_yield("foo\nbar\n")
          .and_yield('baz')
      end

      it 'correctly considers the trailing newline to create a separate, empty chunk' do
        expect(streamed_lines).to eq(['foo', 'bar', 'baz'])
      end
    end

    context 'when the content ends with a newline' do

      before do
        allow(described_class)
          .to receive(:get)
          .and_yield("foobar")
          .and_yield("baz\n")
      end

      it 'calls the block with the content in the correct order' do
        expect(streamed_lines).to eq(['foobarbaz'])
      end
    end

    context 'when a chunk starts with a newline' do

      before do
        allow(described_class).to receive(:get).and_yield("\nfoo")
      end

      it 'calls the block with the empty string from the leading newline' do
        expect(streamed_lines).to eq(['', 'foo'])
      end
    end

    context 'when a chunk contains consecutive newline characters' do

      before do
        allow(described_class).to receive(:get).and_yield("foo\n\nbar")
      end

      it 'calls the block with the empty string from the leading newline' do
        expect(streamed_lines).to eq(['foo', '', 'bar'])
      end
    end

    context 'when the GET request fails' do

      let(:url) { 'https://test.stream_lines.com/fail' }

      before { stub_request(:get, url).to_return(status: 403) }

      it 'raises a StreamLines::Error' do
        expect { stream.each { |line| line } }
          .to raise_error StreamLines::Error, "Failed to download #{url} with code: 403"
      end
    end

    # TODO: (jdlubrano)
    # Figure out how to deactivate WebMock and start the StreamingApi
    # in a separate process.  That way we should get a cleaner look at
    # this gem's memory usage.
    context 'memory efficiency' do
      include StreamingApi::Helpers

      let(:url) { stream_data_url }

      around do |ex|
        run_streaming_api { ex.run }
      end

      it 'can stream large files without using too much memory' do
        max_memory_usage = baseline_memory_usage = GetProcessMem.new.mb

        stream.each do |line|
          max_memory_usage = [max_memory_usage, GetProcessMem.new.mb].max
        end

        expect(max_memory_usage - baseline_memory_usage).to be <= 20
      end
    end
  end

  describe '#each_slice' do
  end
end
