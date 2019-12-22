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

#/usr/bin/snmpwalk -OS -v2c -c gobland 10.100.0.5 NET-SNMP-EXTEND-MIB::nsExtendOutLine
#NET-SNMP-EXTEND-MIB::nsExtendOutLine."MySQLQuestions".1 = STRING: Questions:3359 Com_select:918 Com_update:18 Com_insert:1 Com_delete:2

my $com            = $opt_c;
my $ip             = $opt_i;

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip NET-SNMP-EXTEND-MIB::nsExtendOutLine |" );
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        verbose("$line");
        if ( $line =~ /^NET-SNMP-EXTEND-MIB.*MySQLQuestions".1 = STRING: (.*)$/ ) {
            print $1."\n";
        }
    }
close(SNMPQUERY);
