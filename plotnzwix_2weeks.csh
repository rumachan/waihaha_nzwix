#! /bin/csh -f
#plotwizmet plot data from white island weather station
echo start of plotwizmet_2weeks.csh
#source /home/volcano/.gmt_setenv

#run UTC to local conversion script
echo running UTC to local conversion
/home/volcano/programs/nzwix/timeconv.pl



set gmtversion = `which psxy`
echo "gmtversion=$gmtversion"
set bindir = /home/volcano/programs/nzwix/bin
set outdir = /home/volcano/output/nzwix
set datadir = /home/volcano/data/nzwix
set infile = /home/volcano/data/nzwix/nzwix_data_NZTIME.csv
set outfile = nzwix_2weeks.ps
set gmt = /usr/bin
#set gmt = /opt/local/gmt/GMT4.5.5/bin

###get a 2weeks worth of data
#some lines in data file don't contain real data; 20070912 SS
#need to remove these
#11/09/2007,13:17:00,7,8,9,13,279,274,267,63.7,13.8,0.46,0.00,0.00,14.0,7.0 
#11/09/2007,13:22:00,7,7,10,13,287,279,267,67.2,14.1,0.46,0.00,0.00,14.0,8.1
#11/09/2007,14:00:15,NZWIX,,,,,,,,,,,,,
#11/09/2007,14:10:45,NZWIX,,,,,,,,,,,,,
#11/09/2007,14:16:44,NZWIX,,,,,,,,,,,,,                                  
#11/09/2007,14:21:00,7,9,10,12,288,282,,63.9,13.6,0.40,0.00,0.00,13.9,6.9
#11/09/2007,14:26:00,9,8,12,12,278,284,,66.1,13.8,0.39,0.00,0.00,13.9,7.6

#tail -4032 $infile >! $datadir/2weeksdata.csv
tail -4032 $infile | grep -v NZWIX >! $datadir/2weeksdata.csv
#tail -4032 $infile | grep -v ,, >! $datadir/2weeksdata.csv

$gmt/gmtset PAPER_MEDIA A3
$gmt/gmtset PAGE_ORIENTATION PORTRAIT
$gmt/gmtset INPUT_CLOCK_FORMAT hh:mm:ss INPUT_DATE_FORMAT dd/mm/yyyy
$gmt/gmtset OUTPUT_CLOCK_FORMAT hh:mm OUTPUT_DATE_FORMAT yyyy-mm-dd
$gmt/gmtset PLOT_CLOCK_FORMAT hh 
#$gmt/gmtset PLOT_DATE_FORMAT dd-o-yyyy
$gmt/gmtset PLOT_DATE_FORMAT o-yyyy
$gmt/gmtset TIME_FORMAT_SECONDARY abbreviated
$gmt/gmtset TIME_LANGUAGE US
$gmt/gmtset LABEL_FONT_SIZE 10
$gmt/gmtset HEADER_FONT_SIZE 16
$gmt/gmtset HEADER_OFFSET -3
$gmt/gmtset ANNOT_FONT_SECONDARY 0 
$gmt/gmtset ANNOT_FONT_SIZE_PRIMARY 10
$gmt/gmtset ANNOT_FONT_SIZE_SECONDARY 8
$gmt/gmtset MEASURE_UNIT cm 

echo start plots
#PLOT MEAN WIND DIRECTION
awk ' BEGIN {FS=","};{print$1"T"$2, $8}' $datadir/2weeksdata.csv | awk 'NF==2' >! meanWD.xy
set  R = `$gmt/minmax -I1 -f0T,1f meanWD.xy`
echo plot MWD $R
$gmt/psxy -JX20T/4 $R -Bsas3DS/0S -Bpa1Rf1d/a30f30:"wind direction (deg)"::."Mean Wind Direction (DEG)":WSEn -Sc0.1 -GBlue -N -K -U meanWD.xy >! $outdir/$outfile
rm meanWD.xy

#PLOT MEAN WIND SPEED
awk ' BEGIN {FS=","};{print$1"T"$2, $4}' $datadir/2weeksdata.csv | awk 'NF==2' >! meanWS.xy
set  R = `$gmt/minmax -I1 -f0T,1f meanWS.xy`
echo plot MWS $R
$gmt/psxy -JX20T/4 $R -Bsa7DS/0S -Bpa1Rf1d/a2f1:"wind speed (knots)"::."Mean Wind Speed (knots)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 meanWS.xy >> $outdir/$outfile
rm meanWS.xy

#PLOT HUMIDITY
awk ' BEGIN {FS=","};{print$1"T"$2, $10}' $datadir/2weeksdata.csv | awk 'NF==2' >! humidity.xy
set  R = `$gmt/minmax -I1 -f0T,1f humidity.xy`
echo plot humidity $R
$gmt/psxy -JX20T/4 $R -Bpa1Rf1dS/a10f5:"Humidity (%)"::."Humidity (%)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 humidity.xy >> $outdir/$outfile
rm humidity.xy*

#PLOT TEMPERATURE
awk ' BEGIN {FS=","}; {print$1"T"$2, $11}' $datadir/2weeksdata.csv | awk 'NF==2' >! temperature.xy
set  R = `$gmt/minmax -I1 -f0T,1f temperature.xy`
echo plot temperature $R
$gmt/psxy -JX20T/4 $R -Bpa1Rf1ds/a2f1:"Temperature (DegC)"::."Temperature (DegC)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 temperature.xy >> $outdir/$outfile
rm temperature.xy

#PLOT SOLAR RADIATION
#awk ' BEGIN {FS= ","}; {print$1"T"$2, $12}' $datadir/2weeksdata.csv | awk 'NF==2' >! solar.xy
#set  R = `$gmt/minmax -I1 -f0T,1f solar.xy`
#echo plot solar radiation $R
#$gmt/psxy -JX20T/4 $R -Bpa1Rf1ds/a0.5f0.25:"Solar Radiation (MJ/m^2)"::."Solar Radiation (MJ/m^2)":WsEN -Sc0.1 -GBlue -N -K -O -Y4 solar.xy >> $outdir/$outfile
#rm solar.xy

#PLOT RAINFALL: note doesnt plot if no rain occured in plotting interval
awk ' BEGIN {FS=","}; {print$1"T"$2, $14}' $datadir/2weeksdata.csv | awk 'NF==2' >! rainfall.xy
set num_rain = `cat rainfall.xy | wc -l`
if ($num_rain != 0) then
	set  R = `$gmt/minmax -I1 -f0T,1f rainfall.xy`
	echo plot rainfall $R
	$gmt/psxy -JX20T/4 $R -Bpa1Rf1ds/a1f1:"Rainfall (mm)"::."Rainfall (mm)":WSEn -Sc0.1 -GBlue -N -K -O -Y4.5 rainfall.xy >> $outdir/$outfile
	rm rainfall.xy
endif


##PLOT CUMULATIVE RAINFALL FOR EACH DAY
##echo plot daily rain total
##set yesterday = `date -dyesterday +%d/%m/%Y`
##echo $yesterday
##awk -v date="$yesterday" '$1 ~ date {print $1,$2,$13}' rainfall.xy >! $datadir/yesterdaysrain.xy
##awk '{rain = rain + $3; print $1"T12:00:00", rain}' $datadir/yesterdaysrain.xy | tail -1 >> $datadir/totalrain.xy
##rm rainfall.xy
 
##add uniq to remove duplicates in totalrain.xy.
##uniq $datadir/totalrain.xy $datadir/totalrain_uniq.xy

##tail -21 $datadir/totalrain_uniq.xy >! $datadir/2weeksrain.xy

##set  R = `$gmt/minmax -I1 -f0T,1f $datadir/2weeksrain.xy`
##echo $R total daily rainfall
##psxy -JX20T/4 $R -Bpa1Rf1ds/a2f1:"Rainfall (mm)"::."Daily rainfall (mm)":WSEN -Sb0.7 -GBlue -N -K -O -Y6 $datadir/2weeksrain.xy >> $outdir/$outfile

##rm $datadir/yesterdaysrain.xy
##rm rainfall.xy*
##rm $datadir/2weeksrain.xy

#PLOT BATTERY
awk '  BEGIN {FS=","}; {print$1"T"$2, $15}' $datadir/2weeksdata.csv | awk 'NF==2' >! bat.xy
set  R = `$gmt/minmax -I1 -f0T,1f bat.xy`
echo plot battery voltage $R
$gmt/psxy -JX20T/4 $R -Bpa1Rf1d -Bsa3DS/a1fs1:"Battery Voltage (V)"::."Battery Voltage (V)":WsEN -Sc0.1 -GBlue -N -O -Y4.5 bat.xy >> $outdir/$outfile
rm bat.xy*
rm $outdir/bat.xy*

#ps conversion and copy to webserver on pihanga
echo pstogif
/home/volcano/bin/pstogif.pl $outdir/nzwix_2weeks 300
echo copy to webserver
#cp $outdir/nzwix_2weeks.gif /opt/local/apache/htdocs/volcanoes/whiteis/nzwix
cp $outdir/nzwix_2weeks.gif /var/www/html/nzwix

#copy for tour operators to access
#cp $outdir/nzwix_2weeks.gif /home/volcano/web_page/WhiteIs

