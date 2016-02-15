# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'reifier/version'

Gem::Specification.new do |spec|
  spec.name          = "reifier"
  spec.version       = Reifier::VERSION
  spec.authors       = ["Benny Klotz"]
  spec.email         = ["benny.klotz92@gmail.com"]

  spec.summary       = %q{A threaded rack app server written in pure ruby}
  spec.description   = %q{A rack app server written in pure ruby}
  spec.homepage      = "https://github.com/tak1n/reifier"
  spec.license       = "MIT"

  # Prevent pushing this gem to RubyGems.org by setting 'allowed_push_host', or
  # delete this section to allow pushing this gem to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = 'https://rubygems.org'
  else
    raise "RubyGems 2.0 or newer is required to protect against public gem pushes."
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_dependency 'concurrent-ruby', '~> 1.0'

  spec.add_development_dependency 'bundler', '~> 1.11'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'minitest-reporters', '~> 1.1'
  spec.add_development_dependency 'rubocop', '~> 0.37'
  spec.add_development_dependency 'rack', '~> 2.0.0.alpha'
end
