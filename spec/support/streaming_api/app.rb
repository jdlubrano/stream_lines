# frozen_string_literal: true

require 'sinatra/base'
require 'sinatra/streaming'

class StreamingApi::App < Sinatra::Base
  DATA_FILE = File.join(__dir__, 'data.txt')

  helpers Sinatra::Streaming

  get '/stream_data' do
    stream do |out|
      File.foreach(DATA_FILE) do |line|
        out << line
      end

      out.flush
    end
  end
end
