require 'reifier/server'
require 'reifier/request'
require 'reifier/response'
require 'reifier/version'

module Reifier
  CRLF = "\x0d\x0a".freeze

  # TODO: add more
  STATUS_CODES = { 200 => 'OK', 500 => 'Internal Server Error' }.freeze

  POST = 'POST'.freeze
  PUT  = 'PUT'.freeze
end
