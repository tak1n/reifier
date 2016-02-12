require 'pry'

module Reifier
  class Server
    CR   = "\x0d"     # :nodoc:
    LF   = "\x0a"     # :nodoc:
    CRLF = "\x0d\x0a" # :nodoc:

    attr_reader :app

    def initialize(app)
      @app = app
    end

    def start
      Socket.tcp_server_loop(8080) do |connection|
        connection.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

        request_line = connection.gets

        headers = ''
        while (line = connection.gets)
          break if line == CRLF
          headers << line
        end

        response = request_line + headers
        connection.print "HTTP/1.1 200 OK\r\n" +
                         "Content-Type: text/plain\r\n" +
                         "Content-Length: #{response.bytesize}\r\n" +
                         "Connection: close\r\n"

        connection.print "\r\n"
        connection.print response

        connection.close
      end
    end

    def new_env(method, location, *args)
      {
        'REQUEST_METHOD'    => method,
        'SCRIPT_NAME'       => '',
        'PATH_INFO'         => location,
        'QUERY_STRING'      => location.split('?').last,
        'SERVER_NAME'       => 'localhost',
        'SERVER_PORT'       => '8080',
        'rack.version'      => Rack.version.split('.'),
        'rack.url_scheme'   => 'http',
        'rack.input'        => StringIO.new('').set_encoding(Encoding::ASCII_8BIT),
        'rack.errors'       => StringIO.new(''),
        'rack.multithread'  => false,
        'rack.multiprocess' => false,
        'rack.run_once'     => false
      }
    end
  end
end
