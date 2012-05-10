apache2sqlite
=============
a simple but fast apache2 to sqlite processor, written in Perl. 

##Summary
processes apache2 logs and stores them into a sqlite database 
as fast as possible. benchmark on a heavily utilitzed 
syslog server (2.66Ghz Xeon) still ingested logs at 
around 19,000 log lines per second. 

##Uses
* produce reports and quick metrics.
* quickly reformat logs by time/date or access type
  
##reqirements
1. sqlite3
2. Perl
3. Perl DBI & DBD::SQLite

## Installing Requirements
###ubuntu/debian
`sudo apt-get install libdbd-sqlite3-perl sqlite3`
### Other
1. Download Sqlite3, compile, install, etc: http://www.sqlite.org/download.html
2. cpan install DBI
3. cpan install DBD::SQLite

##Usage
`./apache2sqlite.pl <dbname> <inputfilename>`
###Example
`./apache2sqlite.pl somesite /var/log/apache2/somesite.access.log`

`grep -v "GET /server-status" /var/log/apache2/somesite.access.log | ./apache2sqlite.pl somesite_pruned -`

##Caveats
* The regex used is solid for my particular LogFormat definition. You will need to customize the regex and the fields for your application. I will include in the wiki a handful of other standard apache LogFormat definitions as examples.


