# Reifier

reify

/ˈriːɪˌfaɪ/

(transitive) to consider or make (an abstract idea or concept) real or concrete

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'reifier'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install reifier

## Usage

Use it through rackup:

    $ rackup -s reifier

## Available Options

You can adapt the ThreadPool sized with following option:

    $ rackup -s reifier -O Threads=8

Also the amount of workers is adaptable:

    $ rackup -s reifier -O Workers=5

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tak1n/reifier.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

