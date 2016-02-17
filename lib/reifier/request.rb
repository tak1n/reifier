module Reifier
  class Request
    attr_reader :request_method, :request_path, :protocol, :request_uri

    def initialize(socket, options)
      @socket  = socket
      @body    = StringIO.new('')
      @options = options
    end

    def handle
      handle_request_line
      handle_headers

      handle_body if request_with_body?
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
        'SERVER_SOFTWARE'      => "Reifier #{Reifier::VERSION}",
        'SERVER_NAME'          => @options[:Host],
        'SERVER_PORT'          => @options[:Port].to_s,
        'HTTP_VERSION'         => @protocol,
        'REMOTE_ADDR'          => @socket.addr.last
      }

      @headers.each do |k, v|
        # The environment must not contain the keys HTTP_CONTENT_TYPE or HTTP_CONTENT_LENGTH (use the versions without HTTP_).
        # see http://www.rubydoc.info/github/rack/rack/master/file/SPEC
        if k == 'CONTENT_LENGTH' || k == 'CONTENT_TYPE'
          env[k] = v
        else
          env["HTTP_#{k}"] = v
        end
      end

      env
    end

    private

    def handle_request_line
      # It is possible that gets returns nil
      # "Returns nil if called at end of file" see http://ruby-doc.org/core-2.3.0/IO.html#method-i-gets
      request_line = @socket.gets
      raise EOFError unless request_line
      raise HTTPParseError, "Received #{request_line.inspect}" unless request_line.include?('HTTP')

      request_line_array = request_line.split

      @request_method  = request_line_array[0]
      @request_path    = request_line_array[1].split('?')[0]
      @query_string    = request_line_array[1].split('?')[1] || ''
      @protocol        = request_line_array[2]

      @request_uri = request_line_array[1]
    end

    def handle_headers
      @headers = {}

      while (line = @socket.gets)
        break if line == CRLF
        if line.include?('Host')
          @headers['HOST'] = line.gsub('Host: ', '').strip.chomp
        else
          key   = line.split(':').first.tr('-', '_').upcase
          value = line.split(':').last.strip.chomp
          @headers[key] = value
        end
      end
    end

    def handle_body
      @body = StringIO.new(@socket.readpartial(@headers['CONTENT_LENGTH'].to_i))
    end

    def request_with_body?
      (@request_method == POST || @request_method == PUT) && @headers['CONTENT_LENGTH']
    end
  end
end
