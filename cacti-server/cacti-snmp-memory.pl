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

#/usr/bin/snmpwalk -OS -v2c -c gobland 10.100.0.7 UCD-SNMP-MIB::memory
#UCD-SNMP-MIB::memIndex.0 = INTEGER: 0
#UCD-SNMP-MIB::memErrorName.0 = STRING: swap
#UCD-SNMP-MIB::memTotalSwap.0 = INTEGER: 0 kB
#UCD-SNMP-MIB::memAvailSwap.0 = INTEGER: 0 kB
#UCD-SNMP-MIB::memTotalReal.0 = INTEGER: 1996608 kB
#UCD-SNMP-MIB::memAvailReal.0 = INTEGER: 442796 kB
#UCD-SNMP-MIB::memTotalFree.0 = INTEGER: 442796 kB
#UCD-SNMP-MIB::memMinimumSwap.0 = INTEGER: 16000 kB
#UCD-SNMP-MIB::memShared.0 = INTEGER: 31180 kB
#UCD-SNMP-MIB::memBuffer.0 = INTEGER: 65608 kB
#UCD-SNMP-MIB::memCached.0 = INTEGER: 1108180 kB
#UCD-SNMP-MIB::memSwapError.0 = INTEGER: error(1)
#UCD-SNMP-MIB::memSwapErrorMsg.0 = STRING: Running out of swap space (0)

my $com            = $opt_c;
my $ip             = $opt_i;
my %Result         = ();

open (SNMPQUERY, "/usr/bin/snmpwalk -v2c -c $com $ip UCD-SNMP-MIB::memory |" );
    while (my $line = <SNMPQUERY>){
        chomp ($line);
        verbose("$line");
        if ( $line =~ /^UCD-SNMP-MIB::mem(\w*).\d = INTEGER: (\d*) kB$/ ) {
            $Result{$1}{'data'} = int( $2 / 1024 );
        }
    }
close(SNMPQUERY);

$Result{'Swap'}{'data'} = $Result{'TotalSwap'}{'data'} - $Result{'AvailSwap'}{'data'};
$Result{'Apps'}{'data'} = $Result{'TotalReal'}{'data'} - $Result{'AvailReal'}{'data'} - $Result{'Buffer'}{'data'} - $Result{'Cached'}{'data'} - $Result{'Shared'}{'data'};

foreach my $query (sort keys %Result) {
    print "$query:$Result{$query}{'data'} ";
}
print "\n";
