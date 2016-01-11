require 'rake'
require 'net/http'
require 'json'
require 'uri'
# require 'benchmark'

#Оптимизировать 2-8, переписать базу
class Quiz

  def initialize
    # str = 'Буря %WORD% небо кроет, Вихри снежные крутя'
    # puts Benchmark.measure{ 1000000.times { strip_punctuation(str)  }  }
    # puts Benchmark.measure{ 1000000.times { str.gsub(/\p{P}/, '').strip  }  }
    # puts Benchmark.measure{ 1000000.times { str.gsub(/[[:punct:]]\z/, '').strip  }  }
    json = JSON.parse(File.read('db/pushkin_db.json'))
    title_by_line_base(json)
    word_by_line_base(json)
    word_with_line_end_base(json)
    # puts Benchmark.measure{ 1000000.times { second(str)  }  }
    # puts Benchmark.measure{ 1000000.times { second2(str)  }  }
    sorted_strings_base(json)
    eighth_task_sort_base(json)
    # Benchmark.bm do |x|
    #   x.report("call function") { strip_punctuation(str)  }
    #   x.report("in function") { str.gsub(/\p{P}/, '').strip }
    # end
  end

  def title_by_line_base(json)
    @title_by_line = {}
    json.each do |poem|
      poem['text'].split("\n").each do |str|
        line = str.strip.gsub(/[[:punct:]]\z/, '')
        @title_by_line["#{line}"] = poem['title'].strip
      end
    end
  end

  # def title_by_line_base(json)
  #   @title_by_line = {}
  #   json.each do |poem|
  #     poem['text'].split("\n").each do |str|
  #       line = strip_punctuation(str)
  #       @title_by_line["#{line}"] = strip_punctuation(poem['title'])
  #     end
  #   end
  # end
  # def word_by_line_base(json)
  #   line = key.sub('%WORD%', '').strip.gsub(/[[:punct:]]\z/, '').gsub(/ {2,}/, ' ')
  #   @word_by_line = {}
  #   json.each do |poem|
  #     poem['text'].split("\n").each do |str|
  #       line = strip_punctuation(str)
  #       words = line.split
  #       words.each_with_index do |word, index|
  #         tmp = words.clone
  #         tmp.delete_at(index)
  #         @word_by_line["#{tmp.join(' ')}"] = word
  #       end
  #     end
  #   end
  # end

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
      answer(params)
    # elsif env["REQUEST_PATH"] == "/registration"
    #   puts "#{params['token']}"
    #   puts req.body.read
    #   ['200', {}, [{answer: "снежные"}.to_json]]
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
    Net::HTTP.post_form(URIP, parameters)
    puts params
    puts parameters
  end

  def first(key)
    @title_by_line[key]
  end

  def second(key)
    @word_by_line[key.sub('%WORD%', '')]
  end


  # def second2(key)
  #   @word_by_line["#{key.sub('%WORD%', '').strip.gsub(/[[:punct:]]\z/, '').gsub(/ {2,}/, ' ')}"]
  # end

  # def second3(key)
  #   line = key.gsub('%WORD%', '').strip.gsub(/[[:punct:]]\z/, '').gsub(/ {2,}/, ' ')
  #   @word_by_line[line]
  # end

  # def second4(key)
  #   line = key.gsub('%WORD%', '').strip.gsub(/[[:punct:]]\z/, '').gsub(/ {2,}/, ' ')
  #   @word_by_line[line]
  # end

  def third_fourth(keys)
    answer = []
    keys.split("\n").each do |key|
      answer << @word_with_line_end[key.sub('%WORD%', '')]
    end
    answer.join(',')
  end

  def fifth(key)
    # @word_by_line = {}
    # json.each do |poem|
    #   poem['text'].split("\n").each do |str|
    #     line = str.strip.gsub(/[[:punct:]]\z/, '')
    #     words = line.split
    #     words.each do |word|
    #       buf_word = word.gsub(/[[:punct:]]\z/, '')
    #       key = line.sub(buf_word, '')
    #       @word_by_line[key] = word
    #     end
    #   end
    # end
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
