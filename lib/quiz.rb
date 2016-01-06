require 'rake'
require 'net/http'
require 'json'
require 'uri'

class Quiz

  def initialize
    json = JSON.parse(File.read('db/pushkin_db.json'))
    title_by_line_base(json)
    word_by_line_base(json)
    sorted_strings_base(json)
    eighth_task_sort_base(json)
  end

  def title_by_line_base(json)
    @title_by_line = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = strip_punctuation(str)
        @title_by_line["#{line}"] = strip_punctuation(poem['title'])
      end
    end
  end

  def word_by_line_base(json)
    @word_by_line = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = strip_punctuation(str)
        words = line.split
        words.each_with_index do |word, index|
          tmp = words.clone
          tmp.delete_at(index)
          @word_by_line["#{tmp.join(' ')}"] = word
        end
      end
    end
  end

  def sorted_strings_base(json)
    @sorted_string = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        text = str.gsub(/\p{P}/, '')
        sorted_string = text.gsub(' ', '').split(//).sort.join('')
        @sorted_string[sorted_string] = text
      end
    end
  end

  def eighth_task_sort_base(json)
    @eighth_sort = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        text = str.gsub(/\p{P}/, '')
        sorted_arr = text.gsub(' ', '').split(//).sort
        sorted_arr.each_index do |index|
          tmp = sorted_arr.clone
          tmp.delete_at(index)
          @eighth_sort["#{tmp.join('')}"] = text
        end
      end
    end
  end

  def strip_punctuation(string)
    string.gsub(/\p{P}/, '').strip
  end

  def call(env)
    if env["REQUEST_PATH"] == "/quiz"
      # ['200', {}, []]
      req = Rack::Request.new(env)
      params = JSON.parse( req.body.read )
      puts params
      answer(params)
    elsif env["REQUEST_PATH"] == "/registration"
      # puts "#{params['token']}"
      # puts req.body.read
      ['200', {}, [{answer: "снежные"}.to_json]]
    end
    ['200', {}, []]
  end

  TOKEN = 'f73854323b84f268f9ae8ef277c621f8'
  URIP = URI("http://pushkin.rubyroid.by/quiz")
  def answer(params)
    answer = ''
    key = params['question']
    case params['level']
    when 1
      answer = first(key)
    when 2
      answer = second(key)
    when 3, 4
      answer = third_fourth(key)
    when 5
      answer = fifth(key)
    when 6, 7
      answer = sixth_seventh(key)
    when 8
      answer = eighth(key)
    end
    parameters = {
      answer: answer,
      token: TOKEN,
      task_id:  "#{params['id']}"
    }
    puts parameters
    Net::HTTP.post_form(URIP, parameters)
  end

  def first(key)
    line = strip_punctuation(key)
    @title_by_line[line]
  end

  def second(key)
    key.gsub!('%WORD%', '')
    line = strip_punctuation(key).gsub(/ {2,}/, ' ')
    @word_by_line[line]
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
    line = strip_punctuation(key)
    words = line.split
    words.each_with_index do |word, index|
      tmp = words.clone
      tmp.delete_at(index)
      correct_word = @word_by_line["#{tmp.join(' ')}"]
      unless correct_word.nil?
        answer = "#{correct_word},#{word}"
      end
    end
    answer
  end

  def sixth_seventh(key)
    sorted_key = key.gsub(/(\p{P}| )/, '').split(//).sort.join('')
    @sorted_string[sorted_key]
  end

  def eighth(key)
    answer = ''
    sorted_key = key.gsub(/(\p{P}| )/, '').split(//).sort
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
