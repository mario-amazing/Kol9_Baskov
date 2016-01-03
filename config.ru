require_relative 'lib/quiz'
require 'utf8-cleaner'
use UTF8Cleaner::Middleware
$stdout.sync = true
run Quiz.new
