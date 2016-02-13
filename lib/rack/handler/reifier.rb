require 'rack/handler'
require 'reifier'

module Rack
  module Handler
    module Reifier
      def self.run(app, options = {})
        server = ::Reifier::Server.new(app, options)
        server.start
      end
    end

    register :reifier, Reifier
  end
end
