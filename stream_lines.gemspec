lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "stream_lines/version"

Gem::Specification.new do |spec|
  spec.name          = "stream_lines"
  spec.version       = StreamLines::VERSION
  spec.authors       = ["Joel Lubrano"]
  spec.email         = ["joel.lubrano@gmail.com"]

  spec.summary       = 'A utility to stream lines of a file over HTTP'
  spec.homepage      = 'https://github.com/jdlubrano/stream_lines'
  spec.license       = 'MIT'

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = 'https://github.com/jdlubrano/stream_lines'
  spec.metadata["changelog_uri"] = 'https://github.com/jdlubrano/stream_lines/releases'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end

  spec.bindir        = 'bin'
  spec.executables   = []
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency 'down', '~> 5.2.4'

  spec.add_development_dependency 'awesome_print', '~> 1.8'
  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'bundler-audit'
  spec.add_development_dependency 'bundler-gem_version_tasks'
  spec.add_development_dependency 'byebug'
  spec.add_development_dependency 'charlock_holmes'
  spec.add_development_dependency 'get_process_mem'
  spec.add_development_dependency 'memory_profiler'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.0'
  spec.add_development_dependency 'rubocop', '~> 1.22.1'
  spec.add_development_dependency 'simplecov', '~> 0.17'
  spec.add_development_dependency 'sinatra', '~> 2.0'
  spec.add_development_dependency 'sinatra-contrib', '~> 2.0'
  spec.add_development_dependency 'webrick', '~> 1.7'
  spec.add_development_dependency 'webmock', '~> 3.0'
end
