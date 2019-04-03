#
# status_tracker.py
# V: 1005.1
# compatible with redhat and centos R6
#
import datetime
import time
import subprocess
import select
import re
import os
import threading
import sys

#
def db2connect(exe,db,user,password):
    fnull = open('/dev/null','w') 
    subprocess.call([exe,"connect","to",db,"user",user,"using",password],stdout=fnull,stderr=fnull)
    fnull.close()

def db2terminate(exe):
    fnull = open('/dev/null','w')
    subprocess.call([exe,"terminate"],stdout=fnull,stderr=fnull)
    fnull.close()

def db2write(exe,table,key,value,content):
    db2command = 'delete from '+table+' where '+key+' =\''+value+'\''
    fnull = open('/dev/null','w')
    subprocess.call([exe,db2command],stdout=fnull,stderr=fnull)
    db2command = ' insert into '+table+' values(\''+value+'\',\''+content.strip()+'\')'
    subprocess.call([exe,db2command],stdout=fnull,stderr=fnull)
    subprocess.call([exe,"commit work"],stdout=fnull,stderr=fnull)
    fnull.close()
    return


def netcoolbuildupdate(table,contentparts):
    summary = contentparts[38]
    service = contentparts[39]
    customer = contentparts[46]
    location = contentparts[0]
    row = "update "+ table + " set RAD_SeenByImpact=0,Customer='"+customer+"',Summary='" + summary + "',Service='" + service + \
          "',Location = '" + location + "'" + \
    " where Class = 12000 and RAD_ServiceName ='"+location+"_L3O'"
    return row

def netcoolwrite(exe,db,user,password,table,contentparts):
    filename = datetime.datetime.now().strftime(basepath+"statustracker-%Y%m%d%H%M%S%f")
    fsql = open(filename+'.ncosql','w')
    fsh = open(filename+'.sh','w')
    row = netcoolbuildupdate(table,contentparts) 
    fsql.write(row + '\n') 
    fsql.write("go" + '\n')
    fsql.flush()
    fsql.close()
    fnull = open('/dev/null','w')
    ncline = exe+" "+"-u"+" "+user+" "+"-s"+" "+db+" "+"-p"+" '"+password+"' "+"<"+ " "+filename+".ncosql"
    fsh.write("#!/bin/sh"+'\n')
    fsh.write(ncline+"\n")
    fsh.flush() 
    fsh.close()
    subprocess.call(["chmod","+x",filename+".sh"],stdout=fnull,stderr=fnull)
    subprocess.call(["sh",filename+".sh"],stdout=fnull,stderr=fnull)
    fnull.close()
    os.remove(filename+'.ncosql')
    os.remove(filename+'.sh')
    return

def statuswrite(content,dbexe,ncexe,db,user,password):
    contentparts = content.split('|')
    db2write(dbexe,'l3_status_staging','l3',contentparts[0],content)
    netcoolwrite(ncexe,db,user,password,'alerts.status',contentparts)


def findExpired(now_epoch,maxwait):
    expired = []
    for d in tservices:
      if (int(d['epoch'])+int(maxwait)) <= int(now_epoch):
        thisEntry = {"servicekey":d['servicekey'],"epoch":d['epoch'],"content":d['content']}
        if any(s['servicekey'] == d['servicekey'] for s in expired):
         for s in expired:
          if s['servicekey'] == d['servicekey']:
             eEntry = {"servicekey":s['servicekey'],"epoch":s['epoch'],"content":s['content']}
             expired.remove(dict(eEntry))
        expired.append(dict(thisEntry))
        tservices.remove(dict(thisEntry))
    return expired

def addRow(servicekey,epoch,content):
    for d in tservices:
     if any(d['servicekey'] == servicekey for d in tservices):
       for d in tservices:
          if d['servicekey'] == servicekey:
             thisEntry = {'servicekey':d['servicekey'],'epoch':d['epoch'],'content':d['content']}
             tservices.remove(dict(thisEntry))
    thisrow = {'servicekey':servicekey,'epoch':epoch,'content':content} 
    tservices.append(dict(thisrow))
 
def process_config():
   maxthreads = 10
   trackedfile = 'tracked.log'
   trackedline = 'L3_STATUS_LINE'
   logfile = 'log.log'
   maxwait = 500
   db2exe = 'db2'
   db2db = 'TBSM'
   db2user = 'db2inst1'
   db2password = ''
   ncosqlexe = 'nco_sql'
   netcooldb = 'NCOMS'
   netcooluser = 'root'
   netcoolpassword = ''
   epochindex = 44
   if os.path.isfile(basepath+'status_tracker.conf'):
      cf = open(basepath+'status_tracker.conf','r')
      cflines = cf.readlines()
      for cfline in cflines:
          cflineparts = cfline.split()
          if len(cflineparts) == 2 and cflineparts[0] == 'maxthreads':
             maxthreads = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'trackedfile':
             trackedfile = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'trackedline':
             trackedline = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == basepath+'logfile':
             logfile = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'maxwait':
             maxwait = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'db2exe':
             db2exe = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'db2db':
             db2db = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'db2user':
             db2user = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'db2password':
             db2password = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'ncosqlexe':
             ncosqlexe = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'netcooldb':
             netcooldb = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'netcooluser':
             netcooluser = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'netcoolpassword':
             netcoolpassword = cflineparts[1] 
          elif len(cflineparts) == 2 and cflineparts[0] == 'epochindex':
             epochindex = cflineparts[1] 
          else:
 	     pass
   return maxthreads,trackedfile,trackedline,logfile,maxwait,db2exe,db2db,db2user,db2password,ncosqlexe,netcooldb,netcooluser,netcoolpassword,epochindex 

basepath = ''

if __name__ == "__main__":
 if len(sys.argv) == 2:
  basepath = sys.argv[1]
 else:
  sys.exit()
 threadpool,trackedf,trackedl,logf,maxwait,dbexe,db,dbuser,dbpass,ncoexe,objsdb,objsuser,objspass,eindex = process_config()
 input_tail = subprocess.Popen(['tail','-n','0','-F',trackedf],\
    stdout=subprocess.PIPE,stderr=subprocess.PIPE)
 input_poll = select.poll()
 input_poll.register(input_tail.stdout)
 tservices = []
 th = []
 db2connect(dbexe,db,dbuser,dbpass)

# start the main forever loop
#
 while True:
# non-blocking wait on record sent to input file (tail -F)
     if input_poll.poll(1):
        inputline = input_tail.stdout.readline()
        if trackedl in inputline:
          lineparts = inputline.split("|")
          content = ''
          for p in range(1,len(lineparts)): 
           if p < len(lineparts)-1:
            content = content + lineparts[p] + '|'
           else:
	    content = content + lineparts[p]
          addRow(lineparts[1],lineparts[int(eindex)],content)
     td = datetime.datetime.utcnow()-datetime.datetime(1970,1,1)
     now_epoch = (td.microseconds + (td.seconds + td.days * 24 * 3600) * 10**6) / 10**6 
     expiredServices = findExpired(now_epoch,maxwait)
     for x in expiredServices:
       while threading.activeCount() >= threadpool:
         time.sleep(1)
       th.append(threading.Thread(target=statuswrite,args=(x['content'],dbexe,ncoexe,objsdb,objsuser,objspass)))
       index = len(th)-1
       th[index].start()
     inputline = ""

