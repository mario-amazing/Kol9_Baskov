require 'rake'
require 'net/http'
require 'json'
require 'uri'

class Quiz

  def initialize
    @token = 'f73854323b84f268f9ae8ef277c621f8'
    json = JSON.parse(File.read('db/pushkin_db.json'))
    @title = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = strip_punctuation(str)
        @title["#{line}"] = strip_punctuation(poem['title'].downcase)
      end
    end
    @word = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        str = strip_punctuation(str)
        str.gsub!(/ {2,}/, ' ')
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
        sorted_string.gsub!(/ /, '')
        @sorted_string[sorted_string] = text
      end
    end
    @eighth_sort = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        text = str.split(//).reject { |s| s =~ /[[:punct:]]/ }.join
        sorted_arr = text.gsub(/ /,'')
        sorted_arr = sorted_arr.split(//).sort
        sorted_arr.each_index do |index|
          tmp = sorted_arr.clone
          tmp.delete_at(index)
          @eighth_sort["#{tmp.join('')}"] = text
        end
      end
    end
  end

  def strip_punctuation(string)
    string.strip.gsub(/[[:punct:]]/, '')
  end

  def call(env)
    if env["REQUEST_PATH"] == "/quiz"
      ['200', {}, []]
      req = Rack::Request.new(env)
      params = JSON.parse( req.body.read )
      puts params
      answer(params)
    elsif env["REQUEST_PATH"] == "/registration"
      # puts "#{params['token']}"
      # puts req.body.read
      ['200', {}, [{answer: "снежные"}.to_json]]
    end
  end

  URIP = URI("http://pushkin.rubyroid.by/quiz")
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
    when 8
      answer = eighth(key)
    end
    parameters = {
      answer: answer,
      token: @token,
      task_id:  "#{params['id']}"
    }
    puts parameters
    Net::HTTP.post_form(URIP, parameters)
  end

  def first(key)
# "question"=>"— Она. — «Да кто ж? Глицера ль, Хлоя, Лила?"
# "question"=>"     А Крылов объелся»"
    #"question"=>"(Заснуть ведь общий всем удел)"
    #"question"=>"Он будет без него? Тиран.."
    #"question"=>"Тот не знаком тебе, мы знаем почему "
    line = strip_punctuation(key)
    @title[line]
  end

  def second(key)
# "question"=>"Мои %WORD%, изумруды "
    #"question"=>"И %WORD%, парадоксов друг"
    #"question"=>"%WORD%         Музам мила; на земле Рифмой зовется она"
    #p"question"=>"%WORD% днем и ночью — был бы путь, "
    #p"question"=>"Моя %WORD%, объятая тоской"
    #"question"=>"%WORD% страницы "
    #p"question"=>"Проклятье, %WORD%, и крест, и кнут"
    #"question"=>"Ну, послушайте, %WORD%: жил-был в старые годы"
# "question"=>"Как %WORD% Курилку моего"
    # "question"=>"Я %WORD%, ты картежный вор"
    key.gsub!('%WORD%', '')
    key = strip_punctuation(key)
    key.gsub!(/ {2,}/, ' ')
    @word[key]
  end

  def third_fourth(keys)
  answer = []
    keys.split("\n").each do |key|
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
    sorted_key.gsub!(/ /,'')
    @sorted_string[sorted_key]
  end

  def eighth(key)
    sorted_key = key.gsub(/ /,'')
    sorted_key = sorted_key.split(//).sort
    answer = ''
    sorted_key.each_index do |index|
      tmp = sorted_key.clone
      tmp.delete_at(index)
      tmp = tmp.join('')
      unless @eighth_sort[tmp].nil?
        answer = @eighth_sort[tmp]
        break
      end
    end
    answer
  end

end
