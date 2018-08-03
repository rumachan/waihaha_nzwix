#! /bin/csh -f
#plotnzwix plot data from white island weather station.  Data is retrieved from metservice using nzwix.py
echo start of plotnzwix_daily.csh
#source /home/volcano/.gmt_setenv

#run UTC to local conversion script
echo running UTC to local conversion
#/home/volcano/programs/nzwix/timeconv2.pl
/home/volcano/programs/nzwix/timeconv.pl

#set gmtversion = `which psxy`
#echo "gmtversion=$gmtversion"
set bindir = /home/volcano/programs/wizmet/bin
set outdir = /home/volcano/output/nzwix
set datadir = /home/volcano/data/nzwix
set infile = /home/volcano/data/nzwix/nzwix_data_NZTIME.csv
set outfile = nzwix_daily.ps

#set gmt = /opt/local/gmt/GMT4.5.5/bin
set gmt = /usr/bin/

#get a days worth of data
#some lines in data file don't contain real data; 20070912 SS
#need to remove these
#11/09/2007,13:17:00,7,8,9,13,279,274,267,63.7,13.8,0.46,0.00,0.00,14.0,7.0                
#11/09/2007,13:22:00,7,7,10,13,287,279,267,67.2,14.1,0.46,0.00,0.00,14.0,8.1               
#11/09/2007,14:00:15,NZWIX,,,,,,,,,,,,,                                                    
#11/09/2007,14:10:45,NZWIX,,,,,,,,,,,,,                                                    
#11/09/2007,14:16:44,NZWIX,,,,,,,,,,,,,                                                    
#11/09/2007,14:21:00,7,9,10,12,288,282,,63.9,13.6,0.40,0.00,0.00,13.9,6.9                  
#11/09/2007,14:26:00,9,8,12,12,278,284,,66.1,13.8,0.39,0.00,0.00,13.9,7.6    

#tail -288 $infile >! $datadir/todaysfile.csv
#the grep bit removes anylines with NZWIX or blank fields ",," in them as in the example above
tail -288 $infile | grep -v NZWIX >! $datadir/todaysfile.csv
#tail -288 $infile | grep -v ,, >! $datadir/todaysfile.csv

echo gmtsets
$gmt/gmtset PAPER_MEDIA A3
$gmt/gmtset PAGE_ORIENTATION PORTRAIT
$gmt/gmtset MEASURE_UNIT cm
gmtset INPUT_CLOCK_FORMAT hh:mm:ss INPUT_DATE_FORMAT dd/mm/yyyy
gmtset OUTPUT_CLOCK_FORMAT hh:mm OUTPUT_DATE_FORMAT yyyy-mm-dd
gmtset PLOT_CLOCK_FORMAT hh
gmtset PLOT_DATE_FORMAT dd-o-yyyy
gmtset TIME_FORMAT_SECONDARY abbreviated
gmtset TIME_LANGUAGE US
gmtset LABEL_FONT_SIZE 10
gmtset HEADER_FONT_SIZE 16
gmtset HEADER_OFFSET -3
gmtset ANNOT_FONT_SECONDARY 8
gmtset ANNOT_FONT_SIZE_SECONDARY 12

#PLOT MEAN WIND DIRECTION
awk ' BEGIN { FS=","};{ print$1"T"$2, $8}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/meanWD.xy
set  R = `$gmt/minmax -I1 -f0T,1f $outdir/meanWD.xy`
echo plot MWD $R
$gmt/psxy -JX20T/4 $R -Bsa1DS/0S -Bpa3Hf1h:"time (NZ Local Time)":/a30f30:"wind direction (deg)"::."Mean Wind Direction (DEG)":WSEn -Sc0.1 -GBlue -N -K -U $outdir/meanWD.xy >! $outdir/$outfile
rm $outdir/meanWD.xy

#PLOT MEAN WIND SPEED
awk ' BEGIN {FS=","}; {print$1"T"$2, $4}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/meanWS.xy
set  R = `$gmt/minmax -I1 -f0T,1f $outdir/meanWS.xy`
echo plot MWS $R
$gmt/psxy -JX20T/4 $R -Bsa1DS/0S -Bpa3Hf1h/a2f1:"wind speed (knots)"::."Mean Wind Speed (knots)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/meanWS.xy >> $outdir/$outfile
rm $outdir/meanWS.xy

#PLOT HUMIDITY
awk ' BEGIN {FS=","}; {print$1"T"$2, $10}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/humidity.xy
set  R = `$gmt/minmax -I1 -f0T,1f $outdir/humidity.xy`
echo plot humidity $R
$gmt/psxy -JX20T/4 $R -Bpa3Hf1hS:"time (NZ Local Time)":/a10f5:"Humidity (%)"::."Humidity (%)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/humidity.xy >> $outdir/$outfile
rm $outdir/humidity.xy

#PLOT TEMPERATURE
awk ' BEGIN {FS=","}; {print$1"T"$2, $11}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/temperature.xy
set  R = `$gmt/minmax -I1 -f0T,1f $outdir/temperature.xy`
echo plot temperature $R
$gmt/psxy -JX20T/4 $R -Bpa3Hf1hsa1DS/a2f1:"Temperature (DegC)"::."Temperature (DegC)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/temperature.xy >> $outdir/$outfile
rm $outdir/temperature.xy

#PLOT SOLAR RADIATION
#awk ' BEGIN {FS=","}; {print$1"T"$2, $12}' $datadir/todaysfile.csv | awk 'NF==2' >! solar.xy
#set  R = `$gmt/minmax -I1 -f0T,1f $outdir/solar.xy`
#echo plot solar radiation $R
#$gmt/psxy -JX20T/4 $R -Bpa3Hf1hsa1DS:"time (NZ Local Time)":/a1f0.5:"Solar Radiation (MJ/m^2)"::."Solar Radiation (MJ/m^2)":WsEn -Sc0.1 -GBlue -N -K -O -Y4 $outdir/solar.xy >> $outdir/$outfile
#rm $outdir/solar.xy

#PLOT RAINFALL note doesnt plot if no rain occured in plotting interval
awk ' BEGIN {FS=","}; {print$1"T"$2, $14}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/rainfall.xy
set num_rain = `cat $outdir/rainfall.xy | wc -l`
if ($num_rain != 0) then
	set  R = `$gmt/minmax -I1 -f0T,1f $outdir/rainfall.xy`
	echo plot rainfall $R
	$gmt/psxy -JX20T/4 $R -Bpa3Hf1hs/a1f1:"Rainfall (mm)"::."Rainfall (mm)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/rainfall.xy >> $outdir/$outfile
	rm $outdir/rainfall.xy
endif

#PLOT BATTERY
awk ' BEGIN {FS=","}; {print$1"T"$2, $15}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/bat.xy
set  R = `$gmt/minmax -I1 -f0T,1f $outdir/bat.xy`
echo plot battery voltage $R
$gmt/psxy -JX20T/4 $R -Bpa3Hf1h:"time (NZ Local Time)":/a1fs1:"Battery Voltage (V)"::."Battery Voltage (V)":WsEN -Sc0.1 -GBlue -O -Y4.5 $outdir/bat.xy >> $outdir/$outfile
rm $outdir/bat.xy

#ps conversion and copy to webserver on pihanga
/home/volcano/bin/pstogif.pl $outdir/nzwix_daily 300
#cp $outdir/nzwix_daily.gif /opt/local/apache/htdocs/volcanoes/whiteis/nzwix
cp $outdir/nzwix_daily.gif /var/www/html/nzwix

#and for tour operators to access
#cp $outdir/nzwix_daily.gif /home/volcano/web_page/WhiteIs


