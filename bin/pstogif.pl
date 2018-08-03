#!/usr/bin/perl

$USAGE = "pstogif.pl base[.ps] density\n";
if ($#ARGV != 1) { die "$USAGE";}

$base = $ARGV[0];
$density = $ARGV[1];
#$density = 300;
$xsize = 800;
$ysize = 1132;

# Ghostscript
$GS= $ENV{'GS'} || 'gs';
$GS= 'gs';
#$GS= '/home/mth/bin/gs_6.01 -I/home/mth/Programs/ghostscript/6.01/lib/';
open (GS, "|$GS -q -dNOPAUSE -dNO_PAUSE -sDEVICE=ppmraw -r$density -sOutputFile=$base.ppm $paperopt $base.ps");
close GS;

#print "Now convert ppm to gif\n";

#$cmd = "pnmcrop $base.ppm | pnmscale -xsize $xsize -ysize $ysize | ppmquant 256 | ppmtogif > $base.gif"; system $cmd;
$cmd = "pnmcrop $base.ppm | pnmscale .35 | ppmquant 256 | ppmtogif > $base.gif"; system $cmd;

$cmd = "rm $base.ppm"; system $cmd;

exit;
