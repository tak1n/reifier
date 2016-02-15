require 'rack/handler'
require 'reifier'

module Rack
  module Handler
    module Reifier
      def self.run(app, options = {})
        puts "Reifier #{::Reifier::VERSION} starting.."
        server = ::Reifier::Server.new(app, options)
        server.start
      end

      def self.valid_options
        {
          'Threads=THREADS' => 'Number of threads (default: 5)'
        }
      end
    end

    register :reifier, Reifier
  end
end
