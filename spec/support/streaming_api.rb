# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/streaming'

class StreamingApi < Sinatra::Base
  LARGE_FILE = File.join(__dir__, '..', 'fixtures', 'data.txt')

  helpers Sinatra::Streaming

  get '/stream_big_data' do
    stream do |out|
      File.foreach(LARGE_FILE) do |line|
        out << line
      end

      out.flush
    end
  end
end
