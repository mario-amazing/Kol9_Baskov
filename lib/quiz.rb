require 'rake'
require 'net/http'
require 'json'
require 'cgi'

class Quiz

  def initialize
    @token = 'f73854323b84f268f9ae8ef277c621f8'
    json = JSON.parse(File.read('db/pushkin_db.json'))
    @title = {}
    @token = ''
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = strip_punctuation(str)
        @title["#{line}"] = strip_punctuation(poem['title'].downcase)
      end
    end
    @word = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        str.gsub!(/ {2,}/, ' ')
        str.gsub!(/[,.!:;]/, '')
        str.gsub!(/(^| )($| )/, '')
        words = str.split(' ')
        words.each_with_index do |word, index|
          tmp = words.clone
          tmp.delete_at(index)
          @word["#{tmp.join(' ')}"] = word
        end
      end
    end
    @sorted_string = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        text = str.split(//).reject { |s| s =~ /[[:punct:]]/ }.join
        sorted_string = text.split(//).sort.join(' ')
        @sorted_string[sorted_string] = text
      end
    end
  end

  def strip_punctuation(string)
    string.strip.gsub(/[[:punct:]]\z/, '')
  end

  def call(env)
    # params =  CGI.parse(env["QUERY_STRING"])
    if env["REQUEST_PATH"] == "/quiz"
      req = Rack::Request.new(env)
      params = JSON.parse( req.body.read )
      puts params
      answer(params)
    elsif env["REQUEST_PATH"] == "/registration"
      puts "#{params}"
      puts "#{params['token']}"
      puts "#{env}"
      puts req.body.read
      ['200', {}, [{answer: "снежные"}.to_json]]
    end
  end

  URIP = URI("http://pushkin-contest.ror.by/quiz")
  def answer(params)
    answer = ''
    key = params['question']
    case params['level'].to_i
    when 1
      answer = first(key)
    when 2
      answer = second(key)
    when 3, 4
      answer = third_fourth(key)
    when 5
      answer = fifth(key)
    when 6, 7
      answer = seveth(key)
      # when 8
      # answer = eighth(key)
    end
    parameters = {
      answer: answer,
      token: @token,
      task_id:  params['id'].to_i
    }

    puts parameters
    puts @token
    ['200', {}, [parameters.to_json]]
    # Net::HTTP.post_form(URIP, parameters)
  end

  def first(key)
    line = strip_punctuation(key)
    @title[line]
  end

  def second(key)
    key.gsub!(/%WORD%/, '')
    key.gsub!(/ {2,}/, ' ')
    key.gsub!(/[,.!:;]/, '')
    key.gsub!(/(^| )($| )/, '')
    @word[key]
  end

  def third_fourth(keys)
    answer = []
    keys.split('\n').each do |key|
      answer << second(key)
    end
    answer.join(',')
  end

  def fifth(key)
    answer = ''
    key.gsub!(/ {2,}/, ' ')
    key.gsub!(/[,.!:;]/, '')
    buf = key.split(' ')
    buf.each_with_index do |word, index|
      tmp = buf.clone
      tmp.delete_at(index)
      correct_word = @word["#{tmp.join(' ')}"]
      unless correct_word.nil?
        answer << "#{correct_word},#{word}"
      end
    end
    answer
  end

  def seveth(key)
    sorted_key = key.split(//).sort.join(' ')
    @sorted_string[sorted_key]
  end

  def eighth(key)

  end

end
