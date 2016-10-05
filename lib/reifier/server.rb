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

      puts "# Ruby version: #{RUBY_VERSION}"
      puts "# Min threads: #{@options[:MinThreads]}, max threads: #{@options[:MaxThreads]}"
      puts "# Environment: #{@options[:environment]}"
      puts "# Master PID: #{Process.pid}"
      puts "# Listening on tcp://#{server.addr.last}:#{@options[:Port]}"

      if @options[:Workers]
        start_clustered(server)
      else
        start_single(server)
      end
    end

    private

    def start_single(server)
      puts '# Started in single mode'
      start!(server)
    end

    def start_clustered(server)
      puts '# Started in clustered mode'
      child_pids = []

      puts '# ================================'
      puts "# Spinning up #{@options[:Workers].to_i} Workers"
      @options[:Workers].to_i.times do |i|
        pid = fork do
          start!(server)
        end

        puts "# Worker #{i} started with pid: #{pid}"

        child_pids << pid
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

      loop do
        pid = Process.wait
        STDERR.puts "Process #{pid} crashed"

        child_pids.delete(pid)
        child_pids << spawn_worker(server)
      end
    end


    def threads(min, max)
      @options[:MinThreads] = min
      @options[:MaxThreads] = max
    end

    def workers(count)
      @options[:Workers] = count
    end

    def start!(server)
      pool = Concurrent::ThreadPoolExecutor.new(
        min_threads:     @options[:MinThreads],
        max_threads:     @options[:MaxThreads],
        max_queue:       0,
        fallback_policy: :caller_runs,
      )

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
          ensure
            socket.close
          end
        end.execute
      end
    end
  end
end
