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
      puts "#{request.params}"
      puts "#{env}"
      @token = request.params['token']
      File.write('token', @token)
      answer = second(request.params['question'])
      ['200', {}, [{answer: 'мглою'}.to_json]]
      # Net::HTTP.post_form(URIP, {answer: 'мглою'})
    end
  end

  def answer(params)
    answer = ''
    key = params['question']
    case params['level'].to_i
    when 1
      answer = first(key)
    when 2
      answer = second(key)
    # when 3
      # answer = third(key)
    # when 4
      # answer = fourth(key)
    # when 5
      # answer = fifth(key)
    # when 6
      # answer = sixth(key)
    # when 7
      # answer = seveth(key)
    # when 8
      # answer = eighth(key)
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

  def third(keys)
    keys.split("\n").each do |key|
      second(key)
    end
  end

  def fouth(key)

  end

  def fifth(key)

  end

  def sixth(key)

  end

  def seveth(key)

  end

  def eighth(key)

  end

end
