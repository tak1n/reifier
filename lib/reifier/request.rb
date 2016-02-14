module Reifier
  class Request
    attr_reader :request_method, :request_path, :protocol, :request_uri

    def initialize(options)
      @body    = StringIO.new('')
      @options = options
    end

    def handle(socket)
      handle_request_line(socket)
      handle_headers(socket)

      handle_body(socket) if request_with_body?
    end

    def rack_env
      # See http://www.rubydoc.info/github/rack/rack/master/file/SPEC
      env = {
        'rack.version'         => Rack.version.split('.'),
        'rack.errors'          => STDERR,
        'rack.multithread'     => true,
        'rack.multiprocess'    => false,
        'rack.run_once'        => false,
        'rack.input'           => @body.set_encoding(Encoding::ASCII_8BIT),
        'rack.url_scheme'      => @protocol.split('/').first.downcase,
        'rack.hijack?'         => false,
        'REQUEST_METHOD'       => @request_method,
        'REQUEST_PATH'         => @request_path,
        'REQUEST_URI'          => @request_uri,
        'SCRIPT_NAME'          => '',
        'PATH_INFO'            => @request_path,
        'QUERY_STRING'         => @query_string,
        'SERVER_PROTOCOL'      => @protocol,
        'SERVER_SOFTWARE'      => 'Reifier Toy Server',
        'SERVER_NAME'          => @options[:Host],
        'SERVER_PORT'          => @options[:Port]
      }

      @headers.each do |k, v|
        env["HTTP_#{k}"] = v
      end

      env
    end

    private

    def handle_request_line(socket)
      # It is possible that gets returns nil
      # "Returns nil if called at end of file" see http://ruby-doc.org/core-2.3.0/IO.html#method-i-gets
      request_line = socket.gets
      raise EOFError unless request_line

      request_line_array = request_line.split

      @request_method  = request_line_array[0]
      @request_path    = request_line_array[1]
      @query_string    = request_line_array[1].split('?')[1] || ''
      @protocol        = request_line_array[2]

      @request_uri = @protocol.split('/').first.downcase + '://' + @options[:Host] + ':' + @options[:Port].to_s + @request_path
    end

    def handle_headers(socket)
      @headers = {}

      while (line = socket.gets)
        break if line == CRLF
        if line.include?('Host')
          @headers['Host'] = line.tr('Host: ', '').strip.chomp
        else
          key   = line.split(':').first.tr('-', '_').upcase
          value = line.split(':').last.strip.chomp
          @headers[key] = value
        end
      end
    end

    def handle_body(socket)
      @body = socket.readpartial(@content_length.to_i)
    end

    def request_with_body
      @request_method == POST || @request_method == PUT
    end
  end
end
