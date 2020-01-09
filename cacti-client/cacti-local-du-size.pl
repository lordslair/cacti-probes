#!/usr/bin/perl
use warnings;
use strict;

my %Result;

# Initialisation to avoid undef
my @Coms      = ('/var', '/usr', '/etc', '/tmp', '/home', '/var/lib', '/var/log', '/var/www');
foreach my $Com (@Coms)
{
    $Result{$Com}{'data'} = '0';
    $Result{$Com}{'label'} = $Com;
    $Result{$Com}{'label'} =~ s/\///g;

    # Gathering folder size from du, size in MB
    if ( -d "$Com")
    {
        open (DF, "du -sm $Com 2>&1 |" );
            while (my $row = <DF>) {
                if ( $row =~ /^(\d*)\s*([a-z\/]*)$/ )
                {
                    $Result{$2}{'data'} = $1;
                }
            }
        close DF;
    }
}

# Exceptions
$Result{'/'}{'label'} = 'root';
$Result{'/'}{'data'} = '0';
$Result{'/backup'}{'label'} = 'backup';
$Result{'/backup'}{'data'} = '0';

my @Exceptions = ('/', '/backup');
foreach my $Exception (@Exceptions)
{
    my $size = `df -m | grep '^/.*$Exception\$' | awk '{print \$3}'`;
    chomp $size;
    if ( $size ) { $Result{$Exception}{'data'} = $size }
}

# Merge of initial @Coms and @Exceptions
@Coms = (@Coms, @Exceptions);

foreach my $query (sort @Coms) {
    print "$Result{$query}{'label'}:$Result{$query}{'data'} ";
}
print "\n";
