require 'rack/handler'
require 'reifier'

module Rack
  module Handler
    module Reifier
      DEFAULT_OPTIONS = {
        Workers: 1,
        Threads: 16
      }.freeze

      def self.run(app, options = {})
        options = DEFAULT_OPTIONS.merge(options)
        puts "Reifier #{::Reifier::VERSION} starting.."
        server = ::Reifier::Server.new(app, options)
        server.start
      end

      def self.valid_options
        {
          'Threads=THREADS' => 'Number of threads (default: 16)',
          'Workers=WORKERS' => 'Number of workers (default: 1)'
        }
      end
    end

    register :reifier, Reifier
  end
end
