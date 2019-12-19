#!/usr/bin/perl
use warnings;
use strict;

#/usr/bin/snmpwalk -v2c -c gobland 10.100.0.7 UCD-SNMP-MIB::laLoad
#UCD-SNMP-MIB::laLoad.1 = STRING: 0.00
#UCD-SNMP-MIB::laLoad.2 = STRING: 0.03
#UCD-SNMP-MIB::laLoad.3 = STRING: 0.00

my $com            = $ARGV[0];
my $ip             = $ARGV[1];
my %Result         = ();
my $i              = 0;

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip UCD-SNMP-MIB::laLoad |" );
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        if ( $line =~ /UCD-SNMP-MIB::laLoad[.](\d*) = STRING: ([\d\.]*)$/ ) {
            $Result{"Load$1"} = $2;
            $i++;
        }
    }
close(SNMPQUERY);

foreach my $keys (sort keys %Result) {
    print "$keys:$Result{$keys} ";
}
print "\n";
