module Reifier
  class Response
    attr_accessor :request_method, :request_uri, :status, :headers, :body

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
      socket.print "HTTP/1.1 #{@status} #{HTTP_STATUS_CODES[@status]}\r\n"
    end

    def handle_headers(socket)
      headers = ''
      @headers.each do |k, v|
        headers << "#{k}: #{v}" + CRLF
      end
      headers << 'Connection: close' + CRLF
      headers << CRLF

      socket.print headers
    end

    def handle_body(socket)
      body = ''
      @body.each do |chunk|
        body << chunk
      end

      body << CRLF

      socket.print body
      socket.close
    end
  end
end
