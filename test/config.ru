class MyApp
  def self.call(env)
    if env['REQUEST_PATH'] == '/test'
      require 'pry'
      binding.pry
    end
    [200, { 'Content-Type' => 'text/html' }, ['Hello World']]
  end
end

run MyApp
