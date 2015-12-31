require 'rack'
# require 'net'

class App

  def call(env)
    request = Rack::Request.new(env)
    # require 'pry'; binding.pry
    if env['REQUEST_PATH'] == "/registration" && request.get?
      ['200', {'Content-Type' => 'text/html'}, ["OPA4ki"]]
    else
      ['200', {'Content-Type' => 'text/html'}, ["#{env['QUERY_STRING']}"]]
    end
    # uri = URI("http://pushkin-contest.ror.by/quiz")
    # parameters = {
    #   answer: 'мглою',
    #   token: 'askldfldj',
    #   task_id:  '7890'
    # }
    # Net::HTTP.post_form(uri, parameters)
  end

end
