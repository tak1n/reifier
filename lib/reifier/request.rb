module Reifier
  class Request
    def initialize(socket)
      @socket = socket
      @body   = ''
    end

    def handle
      handle_request_line
      handle_headers

      if @request_method == POST || @request_method == PUT
        handle_body
      end
    end

    def rack_env
      # TODO:
      # Automatically create proper headers
      # See http://www.rubydoc.info/github/rack/rack/master/file/SPEC
      # which are needed and when and how and sosososos
      env = {
        'rack.version'         => Rack.version.split('.'),
        'rack.errors'          => STDERR,
        'rack.multithread'     => false,
        'rack.multiprocess'    => false,
        'rack.run_once'        => false,
        'rack.input'           => StringIO.new(@body).set_encoding(Encoding::ASCII_8BIT),
        'rack.url_scheme'      => @protocol.split('/').first.downcase,
        'REQUEST_METHOD'       => @request_method,
        'REQUEST_PATH'         => @location,
        'REQUEST_URI'          => @location,
        'SCRIPT_NAME'          => '',
        'PATH_INFO'            => @location,
        'QUERY_STRING'         => @query_string,
        'SERVER_PROTOCOL'      => @protocol,
        'SERVER_SOFTWARE'      => 'Reifier Toy Server',
        'SERVER_NAME'          => 'localhost',
        'SERVER_PORT'          => '3000',
        'CONTENT_TYPE'         => '',
        'reifier.socket'       => @socket
      }

      env['CONTENT_LENGTH'] = @content_length if @content_length

      env
    end

    private

    def handle_request_line
      request_line = @socket.gets.split

      @request_method  = request_line[0]
      @location        = request_line[1]
      @query_string    = request_line[1].split('?')[1] || ''
      @protocol        = request_line[2]
    end

    def handle_headers
      @headers = ''
      while (line = @socket.gets)
        break if line == CRLF
        @headers << line

        if line.include?('Content-Length')
          @content_length = line[/\d+/]
        end
      end
    end

    def handle_body
      @body = @socket.readpartial(@content_length.to_i)
    end
  end
end
