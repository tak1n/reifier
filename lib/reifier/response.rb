module Reifier
  class Response
    attr_accessor :status, :headers, :body, :protocol

    def initialize
      @response = ''
    end

    def handle(socket)
      handle_request_line
      handle_headers
      handle_body

      socket.write @response
      socket.close
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
    end
  end
end
