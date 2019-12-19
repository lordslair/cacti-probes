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

#/usr/bin/snmpwalk -v2c -c gobland 10.100.0.7 HOST-RESOURCES-MIB::hrProcessorLoad
#HOST-RESOURCES-MIB::hrProcessorLoad.196608 = INTEGER: 2

my $com            = $opt_c;
my $ip             = $opt_i;
my %Result         = ();
$Result{'Average'} = 0;

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip HOST-RESOURCES-MIB::hrProcessorLoad |" );
    my $cpu = 0;
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        verbose("$line");
        if ( $line =~ /^HOST-RESOURCES-MIB::hrProcessorLoad[.]\d* = INTEGER: (\d*)$/ ) {
            $Result{"Cpu$cpu"} = $1;
            $cpu++;
        }
    }
close(SNMPQUERY);

foreach my $keys (sort keys %Result) {
    if ( $keys =~ /Cpu/ ) {
        print "$keys:$Result{$keys} ";
    }
    $Result{'Sum'} += $Result{$keys}
}

$Result{'Average'} = int($Result{'Sum'} / $cpu);
print "Average:$Result{'Average'}\n";
