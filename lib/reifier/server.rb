module Reifier
  class Server
    def initialize(app, options = {})
      @app     = app
      @options = options
    end

    def start
      server = TCPServer.new(@options[:Host], @options[:Port])

      child_pids = []
      @options[:Workers].to_i.times do
        child_pids << spawn_worker(server)
      end

      Signal.trap 'SIGINT' do
        puts "Cleaning up #{child_pids.length} Workers"
        child_pids.each do |cpid|
          begin
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end

        exit
      end

      puts "# Environment: #{@options[:environment]}"
      puts "# Listening on tcp://#{@options[:Host]}:#{@options[:Port]}"
      puts "# Master PID: #{Process.pid}"
      puts "# Number of Threads used: #{@options[:Threads]}"
      puts "# Number of Workers used: #{@options[:Workers]}"

      loop do
        pid = Process.wait
        STDERR.puts "Process #{pid} crashed"

        child_pids.delete(pid)
        child_pids << spawn_worker
      end
    end

    private

    def spawn_worker(server)
      fork do
        Thread.abort_on_exception = true

        pool  = Concurrent::FixedThreadPool.new(@options[:Threads])

        loop do
          socket = server.accept
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

          pool.post do
            begin
              request  = Request.new(@options)
              response = Response.new

              request.handle(socket)

              response.protocol = request.protocol
              response << @app.call(request.rack_env)

              response.handle(socket)

              log_request request, response if development?
            rescue Exception => e
              log "\nError: #{e.class}\nMessage: #{e.message}\n\nBacktrace:\n\t#{e.backtrace.join("\n\t")}" if development?
              socket.close
            end
          end
        end
      end
    end

    def development?
      @options[:environment] == 'development'
    end

    def log(message)
      puts "[#{Time.now}] #{message}"
    end

    def log_request(request, response)
      puts "[#{Time.now}] \"#{request.request_method} #{request.request_path} #{request.protocol}\" #{response.status}"
    end
  end
end
