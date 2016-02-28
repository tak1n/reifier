require 'rack/handler'
require 'reifier'

module Rack
  module Handler
    module Reifier
      DEFAULT_OPTIONS = {
        MinThreads: 0,
        MaxThreads: 16
      }.freeze

      def self.run(app, options = {})
        options = DEFAULT_OPTIONS.merge(options)
        puts "======= Reifier #{::Reifier::VERSION} starting ======="
        server = ::Reifier::Server.new(app, options)
        server.load_configuration
        server.start
      end

      def self.valid_options
        {
          'MinThreads=MINTHREADS' => 'Number of minimal threads (default: 0)',
          'MaxThreads=MAXTHREADS' => 'Number of minimal threads (default: 16)',
          'Workers=WORKERS'       => 'Number of workers (default: none)'
        }
      end
    end

    register :reifier, Reifier
  end
end
