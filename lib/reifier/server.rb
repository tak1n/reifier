module Reifier
  class Server
    def initialize(app, options = {})
      @app     = app
      @options = options
    end

    def start
      Thread.abort_on_exception = true
      server = TCPServer.new(@options[:Host], @options[:Port])

      puts "# Environment: #{@options[:environment]}"
      puts "# Listening on tcp://#{@options[:Host]}:#{@options[:Port]}"
      puts "# PID: #{Process.pid}"

      loop do
        socket = server.accept
        socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        Thread.new do
          begin
            request  = Request.new(@options)
            response = Response.new

            request.handle(socket)

            response.request_method = request.request_method
            response.request_uri    = request.request_uri
            response.protocol       = request.protocol

            response << @app.call(request.rack_env)

            response.handle(socket)

            log(request, response) if @options[:environment] == 'development'
          rescue EOFError
            # Umad?
          rescue Errno::EPIPE
            # Again mad?
          end
        end
      end
    end

    private

    def log(request, response)
      puts "[#{Time.now}] \"#{request.request_method} #{request.request_path} #{request.protocol}\" #{response.status}"
    end
  end
end
