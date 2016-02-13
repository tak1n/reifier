module Reifier
  class Server
    def initialize(app, options = {})
      @app     = app
      @options = options
    end

    def start
      server = TCPServer.new(@options[:Host], @options[:Port])

      puts "# Environment: #{@options[:environment]}"
      puts "# Listening on tcp://#{@options[:Host]}:#{@options[:Port]}"

      loop do
        connection = server.accept
        connection.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        request = Request.new(connection)
        request.handle

        status, headers, body = @app.call(request.rack_env)

        response = Response.new(connection)
        response.handle(status, headers, body)

        if @options[:environment] == 'development'
          log(request, response)
        end
      end
    end

    private

    def log(request, response)
      STDOUT.puts "[#{Time.now}] \"#{request.request_method} #{request.location} #{request.protocol}\" #{response.status}"
    end
  end
end
