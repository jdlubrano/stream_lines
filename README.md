# StreamLines

An API for streaming files from remote locations one line at a time.

## Background

Some applications run in production environments without writable file system;
usually this is a security measure.  Futhermore, with the proliferation of
container-based production environments, containers may not have access to
tremendous amounts of memory.  Thus, it can be impossible to read large files
unless you read the file into memory in small doses.  A common pattern is to
use a line-delimited file like [JSON Lines](http://jsonlines.org) or a CSV
and to read the file one line at a time in order to iterate over a dataset.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stream_lines'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stream_lines

## Usage

### Reading

#### From a URL

```ruby
url = 'https://my.remote.file/file.txt'
stream = StreamLines::Reading::Stream.new(url)

stream.each do |line|
  # Do something with the line of data
end

# A StreamLines::Reading::Stream object is Enumerable, so you can also use
# any Enumerable methods.

stream.each_slice(100) do |lines|
  # Do something with the 100 lines of data
end
```

## Development

After checking out the repo, run `bin/setup` to install dependencies.
Then, run `rake spec` to run the tests. You can also run `bin/console` for an
interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`.

## Releasing

After merging in the new functionality to the master branch:

```
git checkout master
git pull --prune
bundle exec rake version:bump:<major, minor, or patch>
bundle exec rake release
```

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/jdlubrano/stream_lines. This project is intended to be a
safe, welcoming space for collaboration, and contributors are expected to
adhere to the [code of conduct](https://github.com/jdlubrano/stream_lines/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the
[MIT License](https://opensource.org/licenses/MIT).