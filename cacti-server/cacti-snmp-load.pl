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

#/usr/bin/snmpwalk -v2c -c gobland 10.100.0.7 UCD-SNMP-MIB::laLoad
#UCD-SNMP-MIB::laLoad.1 = STRING: 0.00
#UCD-SNMP-MIB::laLoad.2 = STRING: 0.03
#UCD-SNMP-MIB::laLoad.3 = STRING: 0.00

my $com            = $opt_c;
my $ip             = $opt_i;
my %Result         = ();

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip UCD-SNMP-MIB::laLoad |" );
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        verbose("$line");
        if ( $line =~ /UCD-SNMP-MIB::laLoad[.](\d*) = STRING: ([\d\.]*)$/ ) {
            $Result{"Load$1"} = $2;
        }
    }
close(SNMPQUERY);

foreach my $keys (sort keys %Result) {
    print "$keys:$Result{$keys} ";
}
print "\n";
