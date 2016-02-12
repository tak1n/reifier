class MyApp
  def self.call(env)
    [200, { 'Content-Type' => 'text/html' }, ['Hello World']]
  end
end

run MyApp
