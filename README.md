apache2sqlite
=============
takes apache logs and squirts them into a sqlite database 
as fast as possible. 

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