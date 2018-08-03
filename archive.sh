#! /bin/sh -f
mv /home/volcano/data/nzwix/nzwix_data.csv /home/volcano/data/nzwix/archives/`date -d yesterday +%b%y`.csv
gzip /home/volcano/data/nzwix/archives/`date -d yesterday +%b%y`.csv
mv /home/volcano/data/nzwix/nzwix_data_NZTIME.csv  /home/volcano/data/nzwix/archives/`date -d yesterday +%b%y`_NZTIME.csv
gzip /home/volcano/data/nzwix/archives/`date -d yesterday +%b%y`_NZTIME.csv
