require 'pry'

module Reifier
  class Server
    def initialize(app)
      @app = app
    end

    def start
      Socket.tcp_server_loop(8080) do |connection|
        connection.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        request = Request.new(connection)
        request.handle

        status, headers, body = @app.call(request.rack_env)

        response = Response.new(connection)
        response.handle(status, headers, body)
      end
    end
  end
end
