#! /usr/bin/perl

use Time::Zone;
use Date::Calc qw(Add_Delta_DHMS);

#local time offset
$offset = tz_local_offset($TZ); # in seconds

$infile = "/home/volcano/data/nzwix/nzwix_data.csv";
$outfile = "/home/volcano/data/nzwix/nzwix_data_NZTIME.csv";
#print $infile;
#print $outfile;

open INFILE,  $infile or die "unable to read $infile: $!\n";
open OUTFILE, "> $outfile" or die "unable to open $outfile: $!\n";

while (<INFILE>) {
chomp;


#$yr = substr $_, 6, 4;
#$mon = substr $_, 3 ,2;
#$day = substr $_, 0 ,2;
#$hr = substr $_, 11 ,2;
#$min = substr $_, 14 ,2;
#$sec = substr $_, 17 ,2;
#$data = substr $_, 20, 70;

($date, $time, $data) = split /,/, $_, 3;
#print "$date\n";
#print "$time\n";
#print "$data\n";
($day,$mon,$yr) = split /\//, $date;
($hr,$min,$sec) = split /:/, $time;

($yr2, $mon2, $day2, $hr2, $min2, $sec2) = Add_Delta_DHMS($yr, $mon, $day, $hr, $min, $sec, 0,0,0, $offset);

printf OUTFILE "%02d/%02d/%4d,%02d:%02d:%02d,%-70s\n", $day2, $mon2, $yr2, $hr2, $min2, $sec2, $data;

}

close INFILE;
close OUTFILE;



###############FOR REFERENCE : THIS IS THE PART THAT DOES THE CONVERSION#############
#local time offset
#$offset = tz_local_offset($TZ); # in seconds


#$yr = 2007;
#$mon = 02;
#$day = 28;
#$hr = 14;
#$min = 36;
#$sec = 12;

#($yr2, $mon2, $day2, $hr2, $min2, $sec2) = Add_Delta_DHMS($yr, $mon, $day, $hr, $min, $sec, 0,0,0, $offset);

#printf "%4d/%02d/%02d,%02d:%02d:%02d\n", $yr2, $mon2, $day2, $hr2, $min2, $sec2;

##########################################################################################

