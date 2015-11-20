# extract_sloc.rb - extract_sloc projectName  start_year start_month end_year end_month
# spin through git repository one month at a time from specified start to specified end
#   set HEAD to that point in time
#  collect SLOC information using cloc

require 'Time'
projectName = ARGV[0]
start_month = DateTime.new(ARGV[1].to_i,ARGV[2].to_i,1)
end_month = DateTime.new(ARGV[3].to_i,ARGV[4].to_i,1)
current = start_month
append = ""
until current == end_month do
  gitdate = (current >> 1).strftime("%Y-%m-%d")
  filedate = (current).strftime("%Y-%m-%d")
  system("git checkout `git rev-list -n 1 --first-parent --before=\"#{gitdate} 0:00\" master`")
  system("cloc --quiet --sql=" + projectName + "_cloc.sql" +  append + "-sql-project=" + projectName + "___#{filedate} .")
  current = current >> 1
  append = " --sql-append "
end 

