require 'rubygems'
require 'json'
require 'Time'

def get_content(issue)
  parsed = JSON.parse(issue)
  contents = parsed['content']
  parsed['comments'].each do |c|
    contents << c['content']
  end
return contents
end

file = File.read(ARGV[0]) 
#parsed = JSON.parse(file)
#puts(parsed['content'])
#parsed['comments'].each do |c|
#  puts(c['content'])
#end
puts(get_content(file))
