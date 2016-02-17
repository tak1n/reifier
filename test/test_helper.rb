$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'reifier'

require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'minitest/autorun'
require "minitest/reporters"
Minitest::Reporters.use! [Minitest::Reporters::DefaultReporter.new(:color => true)]
