module Reifier
  class Request
    def initialize(socket)
      @socket = socket
    end

    def handle
      handle_request_line
      handle_headers
    end

    def rack_env
      {
        'REQUEST_METHOD'    => @request_method,
        'SCRIPT_NAME'       => '',
        'PATH_INFO'         => @location,
        'QUERY_STRING'      => @query_string,
        'SERVER_NAME'       => @socket.local_address.getnameinfo.first,
        'SERVER_PORT'       => @socket.local_address.ip_port.to_s,
        'rack.version'      => Rack.version.split('.'),
        'rack.url_scheme'   => @protocol.downcase,
        'rack.input'        => StringIO.new('').set_encoding(Encoding::ASCII_8BIT),
        'rack.errors'       => STDERR,
        'rack.multithread'  => false,
        'rack.multiprocess' => false,
        'rack.run_once'     => false
      }
    end

    private

    def handle_request_line
      request_line = @socket.gets.split

      @request_method  = request_line[0]
      @location        = request_line[1]
      @query_string    = request_line[1].split('?').last
      @protocol        = request_line[2].split('/').first
      @protocol_verion = request_line[2].split('/').last
    end

    def handle_headers
      @headers = ''
      while (line = @socket.gets)
        break if line == CRLF
        @headers << line
      end
    end
  end
end
