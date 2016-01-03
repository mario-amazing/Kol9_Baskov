require 'rack'
require 'net/http'
require 'json'

class Quiz

  def initialize
    json = JSON.parse(File.read('db/pushkin_db.json'))
    @title = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        str.gsub!(/ {2,}/, ' ')
        str.gsub!(/[,.!:;]/, '')
        @title["#{str}"] = poem['title']
      end
    end
    @word = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        str.gsub!(/ {2,}/, ' ')
        str.gsub!(/[,.!:;]/, '')
        buf = str.split(' ')
        buf.each_with_index do |word, index|
          tmp = buf.clone
          tmp.delete_at(index)
          @word["#{tmp.join(' ')}"] = word
        end
      end
    end
  end

  URIP = URI("http://pushkin-contest.ror.by/quiz")
  def call(env)
    request = Rack::Request.new(env)
    if request.path == "/quiz" || request.path == "/quiz/"
      answer(request.params)
    elsif request.path == "/registration" || request.path == "/registration/"
      @token = request.params['token']
      File.write('token', @token)
      answer = second(request.params['question'])
      ['200', {}, [{answer: answer}.to_json]]
      # Net::HTTP.post_form(URIP, {answer: 'мглою'})
    end
  end

  def answer(params)
    answer = ''
    case params['level'].to_i
    when 1
      answer = first(params['question'])
    when 2
      answer = second(params['question'])
    end
    parameters = {
      answer: answer,
      token: '',
      task_id:  "#{params['id']}"
    }
    ['200', {}, [parameters.to_json]]
    # Net::HTTP.post_form(URIP, parameters)
  end

  def first(key)
    key.gsub!(/[,.!:;]/, '')
    key.gsub!(/ {2,}/, ' ')
    @title[key]
  end

  def second(key)
    key.gsub!(/(%WORD%|ORD20)/, '')
    key.gsub!(/ {2,}/, ' ')
    key.gsub!(/[,.!:;]/, '')
    @word[key]
  end

end
