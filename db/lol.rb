#! /usr/bin/env ruby
require 'json'

tempHash = {
  "key_a" => "val_a",
  "key_b" => "val_b"

}
File.open("pushkin_db.json","w") do |f|
  f.write(tempHash.to_json)
end
# require 'pry'; binding.pry
json = JSON.parse(File.read('pushkin_db.json'))
puts json.class
