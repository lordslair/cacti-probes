#!/usr/bin/perl
use warnings;
use strict;

my $etc_dir  = '/etc/rsnapshot';
my $log_dir  = '/var/log/rsnapshot';
my %Result;

# Initialisation to avoid undef
my @Coms      = ('success', 'fail', 'total');
foreach my $Com (@Coms) { $Result{$Com}{'data'} = '0'}

# Gathering enabled backups
open (RSNAPSHOTCONF, "grep ^interval $etc_dir/rsnapshot-*.conf |" );
    while (my $row = <RSNAPSHOTCONF>) {
        if ( $row =~ /$etc_dir\/rsnapshot-(\S*).conf:interval\tdaily/ )
        {
            my $target = $1;
            $Result{$target}{'conffile'} = "$etc_dir/rsnapshot-$target.conf";
            my $logfile = `grep ^logfile $Result{$target}{'conffile'} | awk '{print \$NF}'`;
            chomp ($logfile);
            $Result{$target}{'logfile'} = $logfile;

            open (RSNAPSHOTLOG,"grep daily $Result{$target}{'logfile'} | tail -1 |" );
                while (my $row = <RSNAPSHOTLOG>) {
                    if ( $row =~ /daily: (completed successfully)/ )
                    {
                        $Result{$target}{'daily'} = $1;
                        $Result{'success'}{'data'}++;
                    }
                    else
                    {
                        $Result{'success'}{'data'}++;
                    }
                    $Result{'total'}{'data'}++;
                }
            close RSNAPSHOTLOG;
        }
    }
close RSNAPSHOTCONF;

foreach my $query (@Coms) {
    print "$query:$Result{$query}{'data'} ";
}
print "\n";
