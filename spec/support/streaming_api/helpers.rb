# frozen_string_literal: true

module StreamingApi
  module Helpers
    def run_streaming_api
      WebMock.disable!

      pid = Process.fork { start_server }
      sleep 1

      yield

      Process.kill('TERM', pid)
      WebMock.enable!
    end

    def start_server
      options = {
        Host: '127.0.0.1',
        Port: '4567'
      }

      Rack::Handler::WEBrick.run(StreamingApi::App, options) do |server|
        %i[INT TERM].each { |sig| trap(sig) { server.stop } }
      end
    end

    def stream_data_url
      'http://localhost:4567/stream_data'
    end
  end
end
