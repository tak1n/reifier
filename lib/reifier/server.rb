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
        option = line.split.first.capitalize
        value  = line.split.last

        @options[option.to_sym] = value
      end

      puts "======= Loaded settings from #{path} =======\n"
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

    def spawn_worker(server)
      fork do
        pool = Concurrent::ThreadPoolExecutor.new(
          # min_threads:     [2, Concurrent.processor_count].max,
          # max_threads:     [2, Concurrent.processor_count].max,
          # max_queue:       [2, Concurrent.processor_count].max * 5,
          min_threads:     @options[:MinThreads],
          max_threads:     @options[:MaxThreads],
          max_queue:       0,
          fallback_policy: :caller_runs
        )

        loop do
          socket = server.accept
          socket.setsockopt(Socket::IPPROTO_TCP, Socket::TCP_NODELAY, 1)

          Concurrent::Future.new(executor: pool).execute do
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
          end
        end
      end
    end
  end
end
