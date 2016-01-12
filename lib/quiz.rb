require 'rake'
require 'net/http'
require 'json'
require 'uri'
# require 'benchmark'

#Оптимизировать 2-8, переписать базу
class Quiz
  attr_reader :title_by_line
  TOKEN = 'f73854323b84f268f9ae8ef277c621f8'
  URIP = URI('http://pushkin.rubyroid.by/quiz')

  def initialize
    # str = 'Буря %WORD% небо кроет, Вихри снежные крутя'
    # puts Benchmark.measure{ 1000000.times { strip_punctuation(str)  }  }
    # puts Benchmark.measure{ 1000000.times { str.gsub(/\p{P}/, '').strip  }  }
    # puts Benchmark.measure{ 1000000.times { str.gsub(/[[:punct:]]\z/, '').strip  }  }
    json = JSON.parse(File.read('db/pushkin_db.json'))
    title_by_line_set(json)
    word_by_line_base(json)
    word_with_line_end_base(json)
    sorted_strings_base(json)
    eighth_task_sort_base(json)
  end

  def title_by_line_set(json)
    @title_by_line = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = str.strip.gsub(/[[:punct:]]\z/, '')
        @title_by_line["#{line}"] = poem['title'].strip
      end
    end
  end

  def word_by_line_base(json)
    @word_by_line = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = str.strip.gsub(/[[:punct:]]\z/, '')
        words = line.split
        words.each do |word|
          buf_word = word.gsub(/[[:punct:]]\z/, '')
          key = line.sub(buf_word, '')
          @word_by_line[key] = buf_word
        end
      end
    end
  end

  def word_with_line_end_base(json)
    @word_with_line_end = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = str
        words = line.split
        words.each do |word|
          buf_word = word.gsub(/[[:punct:]]\z/, '')
          key = line.sub(buf_word, '')
          @word_with_line_end[key] = buf_word
        end
      end
    end
  end

  def sorted_strings_base(json)
    @sorted_string = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        text = str.gsub(/\p{P}/, '')
        sorted_string = text.gsub(' ', '').chars.sort.join
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
    params = JSON.parse(Rack::Request.new(env).body.read)
    key = params['question']
    answer = send("level#{params['level']}", key)
    post_params = {
      answer: answer,
      token: TOKEN,
      task_id: params['id']
    }
    Net::HTTP.post_form(URIP, post_params)
    puts params, post_params
    ['200', {}, []]
  end

  def level1(key)
    @title_by_line[key]
  end

  def level2(key)
    @word_by_line[key.sub('%WORD%', '')]
  end

  def level3(keys)
    answer = []
    keys.split("\n").each do |key|
      answer << @word_with_line_end[key.sub('%WORD%', '')]
    end
    answer.join(',')
  end

  def level4(keys)
    answer = []
    keys.split("\n").each do |key|
      answer << @word_with_line_end[key.sub('%WORD%', '')]
    end
    answer.join(',')
  end

  def level5(key)
    words = key.split
    words.each do |word|
      buf_word = word.gsub(/[[:punct:]]\z/, '')
      buf_key = key.sub(buf_word, '')
      correct_word = @word_by_line[buf_key]
      unless correct_word.nil?
        return "#{correct_word},#{buf_word}"
      end
    end
    ''
  end

  def level6(key)
    sorted_key = key.gsub(' ', '').chars.sort.join
    @sorted_string[sorted_key]
  end

  def level7(key)
    sorted_key = key.gsub(' ', '').chars.sort.join
    @sorted_string[sorted_key]
  end

  def level8(key)
    sorted_key = key.gsub(' ', '').chars.sort
    sorted_key.each_index do |index|
      tmp = sorted_key.clone
      tmp.delete_at(index)
      tmp = tmp.join('')
      unless @eighth_sort[tmp].nil?
        return @eighth_sort[tmp]
      end
    end
    ''
  end
end
