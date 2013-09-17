#!/usr/bin/perl

my $pynfs_output = $ARGV[0];

# Print all FAILURE output
open(IN, "<${pynfs_output}") or die "Could not open ${pynfs_output}.\n";
my $failure = 0;
my $totfail = 1;
my $tottest = 1;
my $allfailmessages = "";
my $ENTIREFILE;
foreach(<IN>) {
    my $line = $_;
    $ENTIREFILE .= $line;
    if ($line =~ /.*FAILURE.*/) {
        $allfailmessages .= "$line";
        $failure = 1;
    } elsif ($failure == 1) {
	print $line[0];
        if (substr($line, 0, 1) eq ' ') {
            $allfailmessages .= "$line";
        } else {
            $failure = 0;
        }
    }
    if ($line =~ /Command line asked for (\d+) of (\d+).*/) {
        $tottest = $2;
        $allfailmessages .= "$line";
    }
    if ($line =~ /Of those: (\d+) Skipped, (\d+) Failed, (\d+) Warned, (\d+).*/) {
        $totfail = $2;
#       print "s:${1}  f:${2}  w:${3}  p:${4}\n";
        $allfailmessages .= "$line";
    }
}
close(IN);

#replace "<" or ">" so junit xml doesn't freak out
$ENTIREFILE =~ s/\</\\\</g;
$ENTIREFILE =~ s/\>/\\\>/g;

if ($totfail > 0) {
    print "<testsuite name ='PYNFS' tests='1'  failures='1' time='0'>
                <failure message='\n${ENTIREFILE}'>
                </failure>
                <system-out>${ENTIREFILE}
                </system-out>
          </testsuite>
          ";
} else {
    print "<testsuite failures='0' name ='PYNFS' tests='1' time='0'
           </testsuite>
          ";
}

#                <success message=''/>
