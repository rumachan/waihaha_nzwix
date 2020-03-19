#! /bin/csh -f
#plotnzwix plot data from white island weather station.  Data is retrieved from metservice using nzwix.py
echo start of plotnzwix_daily.csh

#run UTC to local conversion script
echo running UTC to local conversion
/home/volcano/programs/nzwix/timeconv.pl

set bindir = /home/volcano/programs/wizmet/bin
set outdir = /home/volcano/output/nzwix
set datadir = /home/volcano/data/nzwix
set infile = /home/volcano/data/nzwix/nzwix_data_NZTIME.csv
set outfile = nzwix_daily.ps

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

#the grep bit removes anylines with NZWIX or blank fields ",," in them as in the example above
tail -288 $infile | grep -v NZWIX >! $datadir/todaysfile.csv

echo gmtsets
gmt set PS_MEDIA a3
gmt set PS_PAGE_ORIENTATION PORTRAIT
gmt set PROJ_LENGTH_UNIT cm
gmt set FORMAT_CLOCK_IN hh:mm:ss FORMAT_DATE_IN dd/mm/yyyy
gmt set FORMAT_CLOCK_OUT hh:mm FORMAT_DATE_OUT yyyy-mm-dd
gmt set FORMAT_CLOCK_MAP hh
gmt set FORMAT_DATE_MAP dd-o-yyyy
gmt set FORMAT_TIME_SECONDARY_MAP abbreviated
#gmt set GMT_LANGUAGE US
#gmt set FONT_LABEL 10
#gmt set FONT_TITLE 16
#gmt set MAP_TITLE_OFFSET -3
#gmt set FONT_ANNOT_SECONDARY 8
#gmt set FONT_ANNOT_SECONDARY 12

#PLOT MEAN WIND DIRECTION
echo PLOT MEAN WIND DIRECTION
awk ' BEGIN { FS=","};{ print$1"T"$2, $8}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/meanWD.xy
set  R = `gmt info -I1 -f0T,1f $outdir/meanWD.xy`
echo plot MWD $R
gmt psxy -JX20T/4 $R -Bsa1DS/0S -Bpa3Hf1h:"time (NZ Local Time)":/a30f30:"wind direction (deg)"::."Mean Wind Direction (DEG)":WSEn -Sc0.1 -GBlue -N -K -U $outdir/meanWD.xy >! $outdir/$outfile
rm $outdir/meanWD.xy

#PLOT MEAN WIND SPEED
echo PLOT MEAN WIND SPEED
awk ' BEGIN {FS=","}; {print$1"T"$2, $4}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/meanWS.xy
set  R = `gmt info -I1 -f0T,1f $outdir/meanWS.xy`
echo plot MWS $R
gmt psxy -JX20T/4 $R -Bsa1DS/0S -Bpa3Hf1h/a2f1:"wind speed (knots)"::."Mean Wind Speed (knots)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/meanWS.xy >> $outdir/$outfile
rm $outdir/meanWS.xy

#PLOT HUMIDITY
echo PLOT HUMIDITY
awk ' BEGIN {FS=","}; {print$1"T"$2, $10}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/humidity.xy
set  R = `gmt info -I1 -f0T,1f $outdir/humidity.xy`
echo plot humidity $R
gmt psxy -JX20T/4 $R -Bpa3Hf1hS:"time (NZ Local Time)":/a10f5:"Humidity (%)"::."Humidity (%)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/humidity.xy >> $outdir/$outfile
rm $outdir/humidity.xy

#PLOT TEMPERATURE
echo PLOT TEMPERATURE
awk ' BEGIN {FS=","}; {print$1"T"$2, $11}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/temperature.xy
set  R = `gmt info -I1 -f0T,1f $outdir/temperature.xy`
echo plot temperature $R
gmt psxy -JX20T/4 $R -Bpa3Hf1hsa1DS/a2f1:"Temperature (DegC)"::."Temperature (DegC)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/temperature.xy >> $outdir/$outfile
rm $outdir/temperature.xy

#PLOT RAINFALL note doesnt plot if no rain occured in plotting interval
echo PLOT RAINFALL note doesnt plot if no rain occured in plotting interval
awk ' BEGIN {FS=","}; {print$1"T"$2, $14}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/rainfall.xy
set num_rain = `cat $outdir/rainfall.xy | wc -l`
if ($num_rain != 0) then
	set  R = `gmt info -I1 -f0T,1f $outdir/rainfall.xy`
	echo plot rainfall $R
	gmt psxy -JX20T/4 $R -Bpa3Hf1hs/a1f1:"Rainfall (mm)"::."Rainfall (mm)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 $outdir/rainfall.xy >> $outdir/$outfile
	rm $outdir/rainfall.xy
endif

#PLOT BATTERY
echo PLOT BATTERY
awk ' BEGIN {FS=","}; {print$1"T"$2, $15}' $datadir/todaysfile.csv | awk 'NF==2' >! $outdir/bat.xy
set  R = `gmt info -I1 -f0T,1f $outdir/bat.xy`
echo plot battery voltage $R
gmt psxy -JX20T/4 $R -Bpa3Hf1h:"time (NZ Local Time)":/a1fs1:"Battery Voltage (V)"::."Battery Voltage (V)":WsEN -Sc0.1 -GBlue -O -Y4.5 $outdir/bat.xy >> $outdir/$outfile
rm $outdir/bat.xy

#ps conversion and copy to webserver
pushd $outdir
gmt psconvert nzwix_daily.ps -Tg
popd
cp $outdir/nzwix_daily.png /var/www/html/nzwix
