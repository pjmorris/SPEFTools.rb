# repo_cloc.rb - repo_cloc start_year start_month end_year end_month projectname
# spin through git repository one month at a time from specified start to specified end
#   set HEAD to that point in time
#  collect SLOC information using cloc

require 'Time'
start_month = DateTime.new(ARGV[0].to_i,ARGV[1].to_i,1)
end_month = DateTime.new(ARGV[2].to_i,ARGV[3].to_i,1)
current = start_month
until current == end_month do
  gitdate = (current >> 1).strftime("%Y-%m-%d")
  filedate = (current).strftime("%Y-%m-%d")
  system("git checkout `git rev-list -n 1 --first-parent --before=\"#{gitdate} 0:00\" master`")
  system("cloc --quiet --sql=" + ARGV[4] + "_cloc.sql --sql-append -sql-project=" + ARGV[4] + "___#{filedate} .")
  current = current >> 1
end 

