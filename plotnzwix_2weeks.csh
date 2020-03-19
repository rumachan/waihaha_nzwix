#! /bin/csh -f
#plotwizmet plot data from white island weather station
echo start of plotwizmet_2weeks.csh

#run UTC to local conversion script
echo running UTC to local conversion
/home/volcano/programs/nzwix/timeconv.pl



set bindir = /home/volcano/programs/nzwix/bin
set outdir = /home/volcano/output/nzwix
set datadir = /home/volcano/data/nzwix
set infile = /home/volcano/data/nzwix/nzwix_data_NZTIME.csv
set outfile = nzwix_2weeks.ps

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

tail -4032 $infile | grep -v NZWIX >! $datadir/2weeksdata.csv

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

echo start plots
#PLOT MEAN WIND DIRECTION
awk ' BEGIN {FS=","};{print$1"T"$2, $8}' $datadir/2weeksdata.csv | awk 'NF==2' >! meanWD.xy
set  R = `gmt info -I1 -f0T,1f meanWD.xy`
echo plot MWD $R
gmt psxy -JX20T/4 $R -Bsas3DS/0S -Bpa1Rf1d/a30f30:"wind direction (deg)"::."Mean Wind Direction (DEG)":WSEn -Sc0.1 -GBlue -N -K -U meanWD.xy >! $outdir/$outfile
rm meanWD.xy

#PLOT MEAN WIND SPEED
awk ' BEGIN {FS=","};{print$1"T"$2, $4}' $datadir/2weeksdata.csv | awk 'NF==2' >! meanWS.xy
set  R = `gmt info -I1 -f0T,1f meanWS.xy`
echo plot MWS $R
gmt info -JX20T/4 $R -Bsa7DS/0S -Bpa1Rf1d/a2f1:"wind speed (knots)"::."Mean Wind Speed (knots)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 meanWS.xy >> $outdir/$outfile
rm meanWS.xy

#PLOT HUMIDITY
awk ' BEGIN {FS=","};{print$1"T"$2, $10}' $datadir/2weeksdata.csv | awk 'NF==2' >! humidity.xy
set  R = `gmt info -I1 -f0T,1f humidity.xy`
echo plot humidity $R
gmt psxy -JX20T/4 $R -Bpa1Rf1dS/a10f5:"Humidity (%)"::."Humidity (%)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 humidity.xy >> $outdir/$outfile
rm humidity.xy*

#PLOT TEMPERATURE
awk ' BEGIN {FS=","}; {print$1"T"$2, $11}' $datadir/2weeksdata.csv | awk 'NF==2' >! temperature.xy
set  R = `gmt info -I1 -f0T,1f temperature.xy`
echo plot temperature $R
gmt psxy -JX20T/4 $R -Bpa1Rf1ds/a2f1:"Temperature (DegC)"::."Temperature (DegC)":WsEn -Sc0.1 -GBlue -N -K -O -Y4.5 temperature.xy >> $outdir/$outfile
rm temperature.xy

#PLOT SOLAR RADIATION
#awk ' BEGIN {FS= ","}; {print$1"T"$2, $12}' $datadir/2weeksdata.csv | awk 'NF==2' >! solar.xy
#set  R = `gmt/minmax -I1 -f0T,1f solar.xy`
#echo plot solar radiation $R
#$gmt/psxy -JX20T/4 $R -Bpa1Rf1ds/a0.5f0.25:"Solar Radiation (MJ/m^2)"::."Solar Radiation (MJ/m^2)":WsEN -Sc0.1 -GBlue -N -K -O -Y4 solar.xy >> $outdir/$outfile
#rm solar.xy

#PLOT RAINFALL: note doesnt plot if no rain occured in plotting interval
awk ' BEGIN {FS=","}; {print$1"T"$2, $14}' $datadir/2weeksdata.csv | awk 'NF==2' >! rainfall.xy
set num_rain = `cat rainfall.xy | wc -l`
if ($num_rain != 0) then
	set  R = `gmt info -I1 -f0T,1f rainfall.xy`
	echo plot rainfall $R
	gmt psxy -JX20T/4 $R -Bpa1Rf1ds/a1f1:"Rainfall (mm)"::."Rainfall (mm)":WSEn -Sc0.1 -GBlue -N -K -O -Y4.5 rainfall.xy >> $outdir/$outfile
	rm rainfall.xy
endif


#PLOT BATTERY
awk '  BEGIN {FS=","}; {print$1"T"$2, $15}' $datadir/2weeksdata.csv | awk 'NF==2' >! bat.xy
set  R = `gmt info -I1 -f0T,1f bat.xy`
echo plot battery voltage $R
gmt psxy -JX20T/4 $R -Bpa1Rf1d -Bsa3DS/a1fs1:"Battery Voltage (V)"::."Battery Voltage (V)":WsEN -Sc0.1 -GBlue -N -O -Y4.5 bat.xy >> $outdir/$outfile
rm bat.xy*
rm $outdir/bat.xy*

#ps conversion and copy to webserver on pihanga
pushd $outdir
gmt psconvert nzwix_2weeks.ps -Tg
popd
echo copy to webserver
cp $outdir/nzwix_2weeks.png /var/www/html/nzwix

