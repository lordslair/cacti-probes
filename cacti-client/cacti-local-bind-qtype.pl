#!/usr/bin/perl
use warnings;
use strict;

use LWP; 			#debian: libwww-perl
use XML::Simple;		#debian: libxml-simple-perl

my $filename = '/var/tmp/cacti-snmp-bind.XML';
my $now      = time();
my @stats    = stat($filename);
my $ref;
my %Result;

# Initialisation to avoid undef when BIND restarts
my @Coms      = ('Total', 'A', 'AAAA', 'CNAME', 'DNSKEY', 'MX', 'NS', 'SOA', 'TXT');
foreach my $Com (@Coms) { $Result{$Com}{'data'} = '0'}

if ($now - $stats[9] < 60)	# If file fresher than 60s, no HTTP request, use cache
{
    $ref = XMLin($filename, ForceArray => 0, KeyAttr => { server => 'name' });
}
else
{
    my $browser = new LWP::UserAgent;
    my $request = new HTTP::Request( GET => "http://localhost:8053" );
    my $headers = $request->headers();
       $headers->header( 'User-Agent','Mozilla/5.0 (compatible; Konqueror/3.4; Linux) KHTML/3.4.2 (like Gecko)');
       $headers->header( 'Accept', 'text/html, image/jpeg, image/png, text/*, image/*, */*');
       $headers->header( 'Accept-Charset', 'iso-8859-15, utf-8;q=0.5, *;q=0.5');
       $headers->header( 'Accept-Language', 'fr, en');
       $headers->header( 'Referer', 'cacti-snmp-bind.pl');
    my $response = $browser->request($request);

    if ($response->is_success)
    {
        open(my $fh, '>', $filename) or die "Could not open file '$filename' $!";
            print $fh $response->content ;
        close $fh;
        $ref = XMLin($filename, ForceArray => 0, KeyAttr => { server => 'name' });
    }
    else
    {
        print "Oops, no awnser from daemon\n";
    }
}

foreach my $counter (@{$ref->{server}->{counters}})
{
    if ( $counter->{type} eq 'qtype' )
    {
        foreach my $attr (sort @{$counter->{counter}})
        {
            $Result{$attr->{name}}{'data'} = $attr->{content};
            $Result{'Total'}{'data'} += $attr->{content};
        }
    }
}

foreach my $query (@Coms) {
    print "qtype$query:$Result{$query}{'data'} ";
}
print "\n";
