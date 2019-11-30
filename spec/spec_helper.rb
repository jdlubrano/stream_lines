require 'bundler/setup'
require 'byebug'
require 'simplecov'
SimpleCov.start

require 'stream_lines'

require 'awesome_print'
require 'get_process_mem'
require 'memory_profiler'
require 'webmock/rspec'

Dir[File.join(__dir__, 'support', '**', '*.rb')].each { |f| require f }

WebMock.disable_net_connect!(allow_localhost: true)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
