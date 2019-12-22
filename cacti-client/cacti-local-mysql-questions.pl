#!/usr/bin/perl
use strict;
use warnings;

use DBI;

my $db_driver = 'mysql';
my $db_host   = 'localhost';
my $db_port   = '3306';
my $db_pass   = '<password>';
my $db_user   = 'readuser';
my $dsn       = "DBI:$db_driver:host=$db_host;port=$db_port";
my $dbh       = DBI->connect($dsn, $db_user, $db_pass, { RaiseError => 1 }) or die $DBI::errstr;

my %Result;

my @Coms      = ('Questions',
                 'Com_select', 'Com_update',       'Com_insert',        'Com_delete',       'Com_replace',
                 'Com_load',   'Com_update_multi', 'Com_insert_select', 'Com_delete_multi', 'Com_replace_select');
foreach my $Com (@Coms) { $Result{$Com}{'data'} = '0'}

my $status = $dbh->selectall_arrayref("SHOW /*!50002 GLOBAL */ STATUS");
foreach my $row (@$status) {
    $Result{$row->[0]}{'data'} = $row->[1];
}

foreach my $query (@Coms) {
    print "$query:$Result{$query}{'data'} ";
}
print "\n";
