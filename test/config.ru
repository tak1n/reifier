class MyApp
  def self.call(env)
    request = Rack::Request.new(env)
    require 'pry'
    binding.pry
    [200, { 'Content-Type' => 'text/html' }, ['Hello World']]
  end
end

run MyApp
