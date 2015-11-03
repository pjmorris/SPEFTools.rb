
Email:
This is the ‘first draft’ of the data collection pipeline, meaning it can be used to go through all the steps and to produce results, but there’s plenty of stuff that’s inconsistent, inefficient, and some stuff that’s just wrong.  

File:
# Collection and reporting on SPEF data

This file presents the commands used to collect, summarize, and plot selected SPEF context factors, practice adherence measures, and outcome measures for phpMyAdmin.

We collect version control commits and source lines of code (sloc) snapshots, bug reports (issues), and email messages.  In Part 1, we describe how to create data files for each of these data sources, using phpMyAdmin as the example project.  In Part 2, we read the data into R, assemble it into forms suitable for plotting, and generate overview graphs for phpMyAdmin.


## Preliminaries: create a directory to hold the project data
In SPEFTools.rb… 
mkdir pma
mkdir pma/emails
mkdir pma/issues


## run before or after sloc snapshot, but not during… you’ll get results for wherever HEAD is, not the final month
$ cp ../SPEFTools.rb/gllog.awk .
$ git log --pretty=format:"%h ; %ad ; %an ; %ae" --numstat --date=short  | awk -f ../gllog.awk |  awk '{ if (length($1) >= 6) print $0 }' > commits.txt

## copy data file to project data directory
cp commits.txt ../SPEFTools.rb/pma


### You’ll need to install cloc…, e.g. npm cloc
###   http://cloc.sourceforge.net/, https://www.npmjs.com/package/cloc
###   npm install cloc 
### and you’ll need to clone phpmyadmin: 
###   git clone https://github.com/phpmyadmin/phpmyadmin
### In the phpmyadmin repo directory, referencing the SPEFTools.rb directory…

$ ruby ../SPEFTools.rb/extract_sloc.rb phpMyAdmin 2001 04 2015 11
## This takes awhile, ~30 minutes
You should see git reporting a series of HEAD positions, one per month 
Previous HEAD position was bdd6075... better format
HEAD is now at 6f471a6... Bug 424771

## Move the generated sql file containing the SLOC snapshots to the project data directory…
mv phpMyAdmin_cloc.sql ../SPEFTools.rb/pma

## Load sql file…. 
sqlite3  -init phpMyAdmin_cloc.sql
> $ sqlite3  -init phpMyAdmin_cloc.sql
>—  Loading resources from phpMyAdmin_cloc.sql
> 
> SQLite version 3.7.13 2012-07-17 17:46:21
> Enter ".help" for instructions
> Enter SQL statements terminated with a ";"

## Save database so R can see it
sqlite> .backup phpMyAdmin_cloc_db
sqlite> .quit

## Get issues
## get_git_issue creates a json file containing the issue description and comments
## get_git_issue uses 2 github requests per file, so 2500 issues per hour is the max rate, given the 5000/hour request rate limit github imposes.
# Revising get_git_issue to be more efficient about requests would be a great sub-project
# Meanwhile, we do a shell loop to get batches until we have all project issues
 for issue in `seq 1 2000`; do ruby get_git_issue.rb phpmyadmin/phpmyadmin your_gitid your_git_password $issue pma/issues; done;
for issue in `seq 2001 3000`; do ruby get_git_issue.rb phpmyadmin/phpmyadmin your_gitid your_git_password $issue pma/issues; done; &

## Once all the .json files are in the issues directory, summarize: 
ruby extract_issue.rb phpMyAdmin pma/issues > issues.csv
##Add header line: 
ProjectMonth,EventDate,Project,Topic,Source,DocId,creator,assignee,
## Move the issues.csv to the project data directory
mv issues.csv pma

## Get the project’s email archives… phpMyAdmin (and Firefox) make it easy, they’re stored by year-month
## If you don’t have ‘wget’, install it, e.g. run ‘sudo brew install wget’
cd pma/emails
Note: I don’t have this automated… anyone want to write a shell script?
## Pull all of the email archive files for the period being studied… (2001… 2015 for phpMyAdmin, only 2014 shown here)
wget https://lists.phpmyadmin.net/pipermail/developers/2014-January.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-February.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-March.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-April.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-May.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-June.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-July.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-August.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-September.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-October.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-November.txt.gz
wget https://lists.phpmyadmin.net/pipermail/developers/2014-December.txt.gz

## summarize the emails:
ruby extract_email.rb pma/emails phpMyAdmin > pma/emails.csv

## Add header to emails.csv: ProjectMonth,Project,Topic,Source,DocId,reporter,creator,assignee

## After all that, your project data directory should look something close to this:

admins-MacBook-Pro-3:SPEFTools.rb admin$ ls pma
commits.txt		emails.csv		issues.csv		pmadb
emails			issues			phpMyAdmin_cloc.sql


## Start R
## Run the R Code in SPEF_RCode.txt

## Load packages (and install them, if need be)
library(dplyr)
library(lubridate)
library(ggplot2)


## Set working directory to your project data directory
setwd("/Users/admin/github/SPEFTools.rb/pma")

## Examples in SPEF_RCode.txt still need tweaking

#$ plotting an outcome measure and some context factors
ggplot(data=spdf[as.Date(spdf$ProjectMonth) %in% seq(from=as.Date("2001-04-01"), to=as.Date("2014-04-01"),by='month') & spdf$Factor %in% c("VDensity","Churn","Commits","Devs","SLOC"),]) + geom_line(aes(x=ProjectMonth,y=Value,group=Factor)) + facet_grid(Factor~.,scales="free_y") + theme(strip.text.y = element_text(angle=0))

