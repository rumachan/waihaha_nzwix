#
#  gns Wind data ingest program
#
#
# Set to True for logging, False for silent operation
# [Errors are always logged]
DEBUG = False

import socket 
socket.setdefaulttimeout(30)
import ConfigParser, time, urllib, os, sys,traceback

class ingest:
    def __init__(self,inifile):
        'load inifile details'
        self.cfp = ConfigParser.ConfigParser()
        self.cfp.read(inifile)

    def lookup(self,name):
        'change name if alternative available from inifile data'
        if self.cfp.has_option('NAMES',name.lower()):
            return self.cfp.get('NAMES',name.lower())
        else:
            return name

    def reformatline(self,orig):
        'reformat the lines from MetService format to GNS format'
        parts = orig.split(',')
        changed = '%02d/%02d/%04d,%02d:%02d:%02d,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s' % \
            (int(parts[0][6:8]),int(parts[0][4:6]),int(parts[0][0:4]),\
            int(parts[0][8:10]),int(parts[0][10:12]),int(parts[0][12:14]),\
            self.lookup(parts[1]),parts[2],parts[3],parts[4],parts[5],parts[6],parts[7],parts[8],\
	    parts[9],parts[10],parts[11],parts[12],parts[13],parts[14])
        return changed

    def reformatgroup(self,group):
        'reformat all non-blank lines in list'
        lines = group.split('\n')
        text = []
        for line in lines:
            if line:
                text.append(self.reformatline(line))
        return "\n".join(text)

    def sample(self):
        'get GNS data from MetService via an HTTP get request'
        result = ''
        try:
            try:
                f = urllib.urlopen(\
                    'http://metaws.metra.co.nz/Met1minAWS.php?User=GNS_2&Pass=Geonet',\
                    proxies={})
                result = f.read().replace('<br />','')
                f.close()
            except:
                try:
                    f.read()
                    f.close()
                except:
                    pass
        finally:
            urllib.urlcleanup()
        return result

# demo code
#inst = ingest(r'coastguard.ini')
#response = inst.sample()[:-1]
#print 'MetService format:'
#print response
#print
#print 'Coastguard format:'
#cgfmt = inst.reformatgroup(response)
#print cgfmt
#print
#print 'Program - 1 minute sampling:'

# save data as a text file
def save(name,data):
    f = open(name,'a')
    try:
        f.write(data+'\n')
    finally:
        f.close()

# utility functions
def error():
    tb = traceback.format_exception(sys.exc_info()[0],sys.exc_info()[1],sys.exc_info()[2])
    return tb[len(tb)-1].replace('\n','')

def errorstack():
    return ''.join(traceback.format_exception(sys.exc_info()[0],sys.exc_info()[1],sys.exc_info()[2]))

# mainline loop
inst = ingest(r'coastguard.ini')
while 1:
    try:
        response = inst.sample() [:-1]   # remove trailing newline
        if response:
            cgfmt = inst.reformatgroup(response)
            save(r'/home/volcano/data/nzwix/nzwix_data.csv',cgfmt)
            if DEBUG:
                print cgfmt
    except:
        print errorstack()
    time.sleep(300)
