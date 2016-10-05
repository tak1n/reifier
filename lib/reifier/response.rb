module Reifier
  class Response
    attr_accessor :status, :headers, :body, :protocol

    def initialize(socket)
      @socket   = socket
      @response = ''
    end

    def handle
      handle_request_line
      handle_headers
      handle_body

      @socket.write @response
    end

    def <<(rack_return)
      @status  = rack_return[0]
      @headers = rack_return[1]
      @body    = rack_return[2]
    end

    private

    def handle_request_line
      @response << "#{@protocol} #{@status} #{HTTP_STATUS_CODES[@status]}" + CRLF
    end

    def handle_headers
      @headers.each do |k, v|
        @response << "#{k}: #{v}" + CRLF
      end
      @response << 'Connection: close' + CRLF
      @response << CRLF
    end

    def handle_body
      @body.each do |chunk|
        @response << chunk
      end

      @response << CRLF
    ensure
      @body.close if @body.respond_to? :close
    end
  end
end
