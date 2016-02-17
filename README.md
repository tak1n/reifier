# Reifier

reify

/ˈriːɪˌfaɪ/

(transitive) to consider or make (an abstract idea or concept) real or concrete

Reifier is a threaded and pre forked rack app server written in pure ruby.

[![Gem Version](https://badge.fury.io/rb/reifier.svg)](https://badge.fury.io/rb/reifier)
[![Dependency Status](https://gemnasium.com/tak1n/reifier.svg)](https://gemnasium.com/tak1n/reifier)
[![Code Climate](https://codeclimate.com/github/tak1n/reifier/badges/gpa.svg)](https://codeclimate.com/github/tak1n/reifier)
[![Build Status](https://travis-ci.org/tak1n/reifier.svg?branch=master)](https://travis-ci.org/tak1n/reifier)

## Is it any good?

[Yes](http://news.ycombinator.com/item?id=3067434), no really just a fun project use it in production if you want :P

## Y u no benchmark?!

Benchmarking a non feature complete HTTP server is very reasonable but here it is:
[benchmarky marky](https://gist.github.com/tak1n/90c8d59111f0f9a3cd36)

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

You can adapt the ThreadPool size with following option:

    $ rackup -s reifier -O Threads=8

Also the amount of workers is adaptable:

    $ rackup -s reifier -O Workers=5

## Config File

You can also use a config file for these and more settings.

When you are using `rails s` reifier tries to load the file from `Rails.root/config/reifier.rb`

When you are using any other rack app it tries to load the file from `Dir.pwd/config/reifier.rb`

See the [example config](examples/reifier.rb)

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tak1n/reifier.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

