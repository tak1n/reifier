module Reifier
  class Server
    def initialize(app, options = {})
      @app     = app
      @options = options
    end

    def load_configuration
      if defined?(Rails)
        path = Rails.root.join('config/reifier.rb')
      else
        path = Dir.pwd + '/reifier.rb'
      end

      return unless File.exist?(path)

      lines = File.read(path).split("\n")

      lines.each do |line|
        eval(line)
      end

      puts "======= Loaded settings from #{path} =======\n"
    rescue NoMethodError => e
      raise UnsupportedOptionError, "Option #{e.name} is not supported from config file"
    end

    def start
      server = TCPServer.new(@options[:Host], @options[:Port])

      child_pids = []
      @options[:Workers].to_i.times do
        child_pids << spawn_worker(server)
      end

      Signal.trap 'SIGINT' do
        puts "\n======= Cleaning up #{child_pids.length} Workers =======\n"
        child_pids.each do |cpid|
          begin
            Process.kill(:INT, cpid)
          rescue Errno::ESRCH
          end
        end

        exit
      end

      puts "# Ruby version: #{RUBY_VERSION}"
      puts "# Min threads: #{@options[:MinThreads]}, max threads: #{@options[:MaxThreads]}"
      puts "# Environment: #{@options[:environment]}"
      puts "# Number of Workers used: #{@options[:Workers]}"
      puts "# Master PID: #{Process.pid}"
      puts "# Listening on tcp://#{server.addr.last}:#{@options[:Port]}"

      loop do
        pid = Process.wait
        STDERR.puts "Process #{pid} crashed"

        child_pids.delete(pid)
        child_pids << spawn_worker
      end
    end

    private

    def threads(min, max)
      @options[:MinThreads] = min
      @options[:MaxThreads] = max
    end

    def workers(count)
      @options[:Workers] = count
    end

    def spawn_worker(server)
      fork do
        pool = Concurrent::ThreadPoolExecutor.new(
          min_threads:     @options[:MinThreads],
          max_threads:     @options[:MaxThreads],
          max_queue:       0,
          fallback_policy: :caller_runs,
        )

        # Signal.trap 'SIGINT' do
        #   puts "Shutting down thread pool in Worker: #{Process.pid}"
        #   pool.shutdown
        #   pool.wait_for_termination

        #   exit
        # end

        loop do
          socket = server.accept
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

          Concurrent::Future.new(executor: pool) do
            begin
              request  = Request.new(socket, @options)
              response = Response.new(socket)

              request.handle

              response.protocol = request.protocol
              response << @app.call(request.rack_env)

              response.handle
            rescue EOFError
              # nothing, shit happens
            rescue Exception => e
              socket.close

              STDERR.puts ERROR_HEADER
              STDERR.puts "#{e.class}: #{e}"
              STDERR.puts e.backtrace
              STDERR.puts ERROR_FOOTER
            end
          end.execute
        end
      end
    end
  end
end
