require 'rack'
require 'net/http'
require 'json'

class Quiz

  URIP = URI("http://pushkin-contest.ror.by/quiz")
  def call(env)
    request = Rack::Request.new(env)
    # require 'pry'; binding.pry
    if request.path == "/quiz" || request.path == "/quiz/"
      answer(request.params)
    elsif request.path == "/registration" || request.path == "/registration/"
      @token = request.params['token']
      File.write('token', @token)
      ['200', {}, [{answer: 'мглою'}.to_json]]
      # Net::HTTP.post_form(URIP, {answer: 'мглою'})
    end
  end

  def answer(params)
    parameters = {
      answer: 'мглою',
      token: '202',
      task_id:  '2234jklj'
    }
    Net::HTTP.post_form(URIP, parameters)
  end
end
