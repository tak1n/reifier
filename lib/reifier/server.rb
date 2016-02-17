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
              request  = Request.new(socket, @options)
              response = Response.new(socket)

              request.handle

              response.protocol = request.protocol
              response << @app.call(request.rack_env)

              response.handle
            rescue Exception => e
              log_error "\nError: #{e.class}\nMessage: #{e.message}\n\nBacktrace:\n\t#{e.backtrace.join("\n\t")}"
              socket.close
            end
          end
        end
      end
    end

    def log_error(message)
      STDERR.puts "[#{Time.now}] #{message}"
    end
  end
end
