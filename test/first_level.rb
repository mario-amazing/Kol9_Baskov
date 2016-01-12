require 'benchmark'
require_relative '../lib/quiz'

quiz = Quiz.new

lines = quiz.title_by_line.keys
Benchmark.bm do |x|
  x.report { 1_000_000.times { quiz.first(lines.sample) } }
end
