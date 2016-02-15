module Reifier
  class Server
    def initialize(app, options = {})
      @app     = app
      @options = options
    end

    def start
      Thread.abort_on_exception = true
      Signal.trap 'SIGINT' do
        puts "\nCleaning up nothing for now..."
        exit
      end

      server = TCPServer.new(@options[:Host], @options[:Port])

      threads = @options[:Threads] || 5
      pool   = Concurrent::FixedThreadPool.new(@options[:Threads] || 5)

      puts "# Environment: #{@options[:environment]}"
      puts "# Listening on tcp://#{@options[:Host]}:#{@options[:Port]}"
      puts "# PID: #{Process.pid}"
      puts "# Number of Threads used: #{threads}"

      loop do
        socket = server.accept
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        # Thread.new do
        pool.post do
          begin
            request  = Request.new(@options)
            response = Response.new

            request.handle(socket)

            response.protocol = request.protocol
            response << @app.call(request.rack_env)

            response.handle(socket)

            log_request request, response if development?
          rescue Exception => e
            log "\nError: #{e.class}\nMessage: #{e.message}\n\nBacktrace:\n\t#{e.backtrace.join("\n\t")}" if development?
            socket.close
          end
        end
      end
    end

    private

    def development?
      @options[:environment] == 'development'
    end

    def log(message)
      puts "[#{Time.now}] #{message}"
    end

    def log_request(request, response)
      puts "[#{Time.now}] \"#{request.request_method} #{request.request_path} #{request.protocol}\" #{response.status}"
    end
  end
end
