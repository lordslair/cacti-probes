#!/usr/bin/perl
# Inspired from https://github.com/Busindre/Apache-mod_status-Cacti
use warnings;
use strict;

use LWP; 			#debian: libwww-perl

my $filename = '/var/tmp/cacti-local-workers';
my $now      = time();
my @stats    = stat($filename);
my $ref;
my %Result;

#   "_" Waiting for Connection, "S" Starting up, "R" Reading Request,
#   "W" Sending Reply, "K" Keepalive (read), "D" DNS Lookup,
#   "C" Closing connection, "L" Logging, "G" Gracefully finishing,
#   "I" Idle cleanup of worker, "." Open slot with no current process

# Initialisation to avoid undef when Apache restarts
my @Coms      = ('_', 'S', 'R', 'W', 'K', 'D', 'C', 'L', 'G', 'I', '.');
foreach my $Com (@Coms) { $Result{$Com}{'data'} = '0'}

if ( (-e $filename) && ($now - $stats[9] < 60))	# If file fresher than 60s, no HTTP request, use cache
{
}
else
{
    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://localhost/server-status?auto" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'cacti-local-apache-workers.pl');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
            print $fh $response->content ;
        close $fh;
    }
    else
    {
        print "Oops, no awnser from daemon\n";
    }
}

open(my $fh, '<', $filename) or die "Could not open file '$filename' $!";
    while (my $row = <$fh>) {
        if ( $row =~ /^Scoreboard: (.*)/ )
        {
            my @workers = $1;
            $Result{$_}{'data'}++ for split //, $workers[0];
        }
    }
close $fh;

# To avoit weird '_' and '.' sent by SNMP
$Result{'_O'}{'data'} = $Result{'.'}{'data'};
$Result{'_W'}{'data'} = $Result{'_'}{'data'};

# To remove these keys before the final loop
delete $Result{'.'};
delete $Result{'_'};

foreach my $query (sort keys %Result) {
    print "thread$query:$Result{$query}{'data'} ";
}
print "\n";
