#! /bin/csh -f

cd /home/volcano/programs/nzwix

set check = `ps -ef | grep nzwix.py | grep -v grep | wc -l`
#echo $check

if  ( $check == 1 ) then
	echo nzwix.py is running
else if ( $check > 1 ) then
	echo too many instances of this program are running
else
	echo program is not running
/usr/bin/python nzwix.py & 
exit

	echo the program nzwix.py has been restarted
endif


