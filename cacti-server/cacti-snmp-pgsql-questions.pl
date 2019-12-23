#!/usr/bin/perl
use warnings;
use strict;

use Getopt::Std;

our ($opt_h,$opt_v,$opt_c,$opt_i);
getopts('hvc:i:p:');

usage() && exit if (($opt_h) || (!$opt_i));
sub verbose { if ($opt_v) {my $text2verb = join(' ', @_);print "[ ".$text2verb."\n"} }
sub usage {
  print STDERR "-h : Help\n";
  print STDERR "-c : SNMP Community\n";
  print STDERR "-v : Verbose Mode\n";
  print STDERR "-i : IP to check\n";
}

#/usr/bin/snmpwalk -v2c -cgobland 10.100.0.3 NET-SNMP-EXTEND-MIB::nsExtendOutLine
#NET-SNMP-EXTEND-MIB::nsExtendOutLine."PGSQLQuestions".1 = STRING: tup_fetched:837380 tup_returned:23867494 tup_inserted:0 tup_updated:0 tup_deleted:0 Questions:24704874

my $com            = $opt_c;
my $ip             = $opt_i;

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip NET-SNMP-EXTEND-MIB::nsExtendOutLine |" );
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        verbose("$line");
        if ( $line =~ /^NET-SNMP-EXTEND-MIB.*PGSQLQuestions".1 = STRING: (.*)$/ ) {
            print $1."\n";
        }
    }
close(SNMPQUERY);
