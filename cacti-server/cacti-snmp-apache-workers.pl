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

# /usr/bin/snmpwalk -OS -v2c -c gobland 10.100.0.2 NET-SNMP-EXTEND-MIB::nsExtendOutLine
# NET-SNMP-EXTEND-MIB::nsExtendOutLine."Apache-workers".1 = STRING: C:0 D:0 G:0 I:0 K:0 L:0 R:0 S:0 W:1 _O:142 _W:7

my $com            = $opt_c;
my $ip             = $opt_i;

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip NET-SNMP-EXTEND-MIB::nsExtendOutLine |" );
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        verbose("$line");
        if ( $line =~ /^NET-SNMP-EXTEND-MIB::nsExtendOutLine."Apache-workers".1 = STRING: (.*)$/ ) {
            print $1."\n";
        }
    }
close(SNMPQUERY);
