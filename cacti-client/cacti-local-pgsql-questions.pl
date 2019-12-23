#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my $db_driver = 'Pg';
my $db_host   = 'localhost';
my $db_port   = '5432';
my $db_pass   = '<password>';
my $db_user   = 'readuser';
my $db_name   = 'postgres';
my $dsn       = "DBI:$db_driver:dbname=$db_name;host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, $db_user, $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

my %Result;

my @Coms      = ('tup_fetched', 'tup_returned', 'tup_inserted', 'tup_updated', 'tup_deleted');
foreach my $Com (@Coms) { $Result{$Com}{'data'} = '0'}

my $status = $dbh->selectall_arrayref("SELECT tup_fetched,tup_returned,tup_inserted,tup_updated,tup_deleted FROM pg_stat_database");

foreach my $db_array (@$status) {
    $Result{'tup_fetched'}{'data'}  += $db_array->[0];
    $Result{'tup_returned'}{'data'} += $db_array->[1];
    $Result{'tup_inserted'}{'data'} += $db_array->[2];
    $Result{'tup_updated'}{'data'}  += $db_array->[3];
    $Result{'tup_deleted'}{'data'}  += $db_array->[4];
}

my $Questions  = $Result{'tup_fetched'}{'data'} + $Result{'tup_returned'}{'data'} + $Result{'tup_inserted'}{'data'};
   $Questions += $Result{'tup_updated'}{'data'} + $Result{'tup_deleted'}{'data'};

foreach my $query (@Coms) {
    print "$query:$Result{$query}{'data'} ";
}
print 'Questions:'.$Questions;
print "\n";
