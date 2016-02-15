HTML = <<-eos
  <form method="post" action="/test">
    <input type="text" name="Name">
    <input type="password" name="Password">
    <input type="submit">
  </form>
eos

class MyApp
  def self.call(env)
    if env['REQUEST_PATH'] == '/test'
      require 'pry'
      binding.pry
    end
    [200, { 'Content-Type' => 'text/html' }, [HTML]]
  end
end

use Rack::Lock
run MyApp
