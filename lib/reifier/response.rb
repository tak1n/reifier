module Reifier
  class Response
    attr_reader :status

    def initialize(socket)
      @socket = socket
    end

    def handle(status, headers, body)
      @status  = status
      @headers = headers
      @body    = body

      handle_request_line
      handle_headers
      handle_body
    end

    private

    def handle_request_line
      @socket.print "HTTP/1.1 #{@status} #{STATUS_CODES[@status]}\r\n"
    end

    def handle_headers
      headers = ''
      @headers.each do |k, v|
        headers << "#{k}: #{v}" + CRLF
      end
      headers << 'Connection: close' + CRLF
      headers << CRLF

      @socket.print headers
    end

    def handle_body
      body = ''
      @body.each do |chunk|
        body << chunk
      end

      body << CRLF

      @socket.print body
      @socket.close
    end
  end
end
