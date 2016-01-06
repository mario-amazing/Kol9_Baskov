require_relative 'lib/quiz'
require 'rake'
$stdout.sync = true

Rack::Handler::Thin.run(Quiz.new)
