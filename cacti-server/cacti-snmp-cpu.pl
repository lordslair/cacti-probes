#!/usr/bin/perl
use warnings;
use strict;

#/usr/bin/snmpwalk -v2c -c gobland 10.100.0.7 HOST-RESOURCES-MIB::hrProcessorLoad
#HOST-RESOURCES-MIB::hrProcessorLoad.196608 = INTEGER: 2

my $com            = $ARGV[0];
my $ip             = $ARGV[1];
my %Result         = ();
$Result{'Average'} = 0;

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip HOST-RESOURCES-MIB::hrProcessorLoad |" );
    my $cpu = 0;
    while (my $line = <SNMPQUERY>){
        chomp ($line);
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
