require_relative 'lib/quiz'
require 'utf8-cleaner'
use UTF8Cleaner::Middleware

run Quiz.new
