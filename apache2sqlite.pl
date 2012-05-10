#!/usr/bin/perl -w

use DBI;
use strict;

##############################################
# apache2sqlite.pl
# Nathan Hubbard @n8foo
# Mon Apr 30 20:24:03 CDT 2012
##############################################
# takes apache logs and squirts them into 
# sqlite database as fast as possible.
# 
# reqirements: sqlite3 ; perl-libdbd-sqlite3
# ubuntu/debian: sudo apt-get install libdbd-sqlite3-perl sqlite3
##############################################

my $DEBUG=0;
my $END=0;

my $database = $ARGV[0];
my $filename = $ARGV[1];

# set up the monthabbr to month hash
my %abbr2num = ('Jan' => 1, 'Feb' => 2, 'Mar' => 3, 'Apr' => 4, 'May' => 5, 'Jun' => 6,
                'Jul' => 7, 'Aug' => 8, 'Sep' => 9, 'Oct' => 10, 'Nov' => 11, 'Dec' => 12);

# set up connection to sqlite
my $dbh = DBI->connect("dbi:SQLite:dbname=$database.db",'','',{'RaiseError' => 1, 'AutoCommit' => 0});

# initial database creation
$dbh->do("PRAGMA synchronous = OFF;");
$dbh->do("CREATE TABLE data (
        hostname, ip, site, user, 
        day, month, year, hour, minute,
        time, method, url, querystring, protocol,
        status, bytes, bytes_recv, bytes_sent, user_agent)") or die "Couldn't create database: " . $dbh->errstr;;
#$dbh->do("create index index_ on data(ip);") or die "Couldn't create index: " . $dbh->errstr;

open FILE, $filename or die $!;

# prepare statement handle with DB query
my $sth = $dbh->prepare("INSERT INTO data
      ( hostname, ip, site, user, 
        day, month, year, hour, minute,
        time, method, url, querystring, protocol,
        status, bytes, bytes_recv, bytes_sent, user_agent)
      VALUES
      ( ?, ?, ?, ?,
        ?, ?, ?, ?, ?, 
        ?, ?, ?, ?, ?, 
        ?, ?, ?, ?, ?)") or print "Couldn't prepare statement: " . $dbh->errstr;

# MAIN LOOP

my $count=0;
while (<FILE>) {
  $count++; 
  if ($END) { last if ( $count > 1000000 ); }
  print "\ntotal rows added: $count ; errors: " if ($count % 10000 == 0); 
  if( $_ =~ m/^(\S+) +(\d+) (\S+) (\S+) (\S+) (\S+) (\S+) (\[.*\]) (\d+) (\w+) (\S+) \"(\S*)\" (\S*) (\S+) (\S+) (\S+) (\S+) \"(\S*)\" \"(\S*)\" \"(\S*)\" \"((\S+, )*(\S*))\" \"(.*)\"$/ ) {

    if ($DEBUG) { print qq($1\n $2\n $3\n $4\n $5\n $6\n $7\n $8\n $9\n $10\n $11\n $12\n $13\n $14\n $15\n $16\n $17\n $18\n $19\n $20\n $21\n $22\n $23\n $24\n); }

    my $hostname        =   $4;
    my $ip              =   $5;
    my $site            =   $6;
    my $user            =   $7;
    my $datetime        =   $8;
    my $time            =   $9; # in microseconds
    my $method          =   $10;
    my $url             =   $11;
    my $querystring     =   $12;
    my $protocol        =   $13;
    my $status          =   $14;
    my $bytes           =   $15; # excluding headers
    my $bytes_recv      =   $16; # including headers
    my $bytes_sent      =   $17; # including headers
    my $account         =   $18;
    my $phpsessid       =   $19;
    my $referer         =   $20;
    my $x_fwd           =   $23;
    my $user_agent      =   $24;


    my ( $day, $monthabbr, $year, $hour, $minute, $month);
    if ( $datetime =~ m/^\[(\d+)\/(\w+)\/(\d\d\d\d):(\d+):(\d+):(\d+) .*$/ ) {
        $day         = $1; # int.
        $monthabbr   = $2;
        $year        = $3; # int.
        $hour        = $4; # int.
        $minute      = $5; # int.
        $month = $abbr2num{$monthabbr};
    } else {
        print qq(could not match datetime: $datetime\n);
        next;
    }
          

      $sth->bind_param(1, $hostname);
      $sth->bind_param(2, $ip);
      $sth->bind_param(3, $site);
      $sth->bind_param(4, $user);
      $sth->bind_param(5, $day);
      $sth->bind_param(6, $month);
      $sth->bind_param(7, $year);
      $sth->bind_param(8, $hour);
      $sth->bind_param(9, $minute);
      $sth->bind_param(10, $time);
      $sth->bind_param(11, $method);
      $sth->bind_param(12, $url);
      $sth->bind_param(13, $querystring);
      $sth->bind_param(14, $protocol);
      $sth->bind_param(15, $status);
      $sth->bind_param(16, $bytes);
      $sth->bind_param(17, $bytes_recv);
      $sth->bind_param(18, $bytes_sent);
      $sth->bind_param(19, $user_agent);
      $sth->execute;
      $dbh->commit if ($count % 1000 == 0);
  
  } else {
    print "x";
    if ($DEBUG) { print qq(log line not parsed correctly $_); }
  }

   #print "\n" if ($count % 1000 == 0); 
}
close FILE;

undef($dbh);

exit 0
