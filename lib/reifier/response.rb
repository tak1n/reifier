module Reifier
  class Response
    attr_accessor :request_method, :request_uri, :status, :headers, :body, :protocol

    def handle(socket)
      handle_request_line(socket)
      handle_headers(socket)
      handle_body(socket)
    end

    def <<(rack_return)
      @status  = rack_return[0]
      @headers = rack_return[1]
      @body    = rack_return[2]
    end

    private

    def handle_request_line(socket)
      socket.write "#{@protocol} #{@status} #{HTTP_STATUS_CODES[@status]}" + CRLF
    end

    def handle_headers(socket)
      headers = ''
      @headers.each do |k, v|
        headers << "#{k}: #{v}" + CRLF
      end
      headers << 'Connection: close' + CRLF
      headers << CRLF

      socket.write headers
    end

    def handle_body(socket)
      body = ''
      @body.each do |chunk|
        body << chunk
      end

      body << CRLF

      socket.write body
      socket.close
    end
  end
end
