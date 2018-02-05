#!/bin/sh

#DATE and TIME
datetime=`date +"%Y/%m/%d% %H:%M:%S"`
minute=$(date "+%M");

#LOADS
loads=`uptime |  awk -F'averages:' '{print $2}' | tr -d " "`
      
#SYSTEM TEMPERATURE        
temps=`/sbin/sysctl -a | grep tempe |  awk -F':' '{print $2}' | tr " " "," | tr -d "C\n"`

#HDDs TEMPERATURE        
if [ $(( $minute % 10 )) -eq 0 ] ;
then
    #read smart
    hdd1=`/usr/local/sbin/smartctl -a /dev/ad6 | grep "Temperature_Celsius" | awk -F " " '{print $10}'`
    hdd2=`/usr/local/sbin/smartctl -a /dev/ad8 | grep "Temperature_Celsius" | awk -F " " '{print $10}'`
    rm /usr/NET/www_pub/hdd_10min.txt
    touch /usr/NET/www_pub/hdd_10min.txt
    hdd=`cat /usr/NET/www_pub/hdd_10min.txt`
    #write
    hdd=$hdd1,$hdd2;
    echo $hdd >> /usr/NET/www_pub/hdd_10min.txt
else
    if [ ! -f /usr/NET/www_pub/hdd_10min.txt ]; then
        hdd1=`/usr/local/sbin/smartctl -a /dev/ad6 | grep "Temperature_Celsius" | awk -F " " '{print $10}'`
	hdd2=`/usr/local/sbin/smartctl -a /dev/ad8 | grep "Temperature_Celsius" | awk -F " " '{print $10}'`
	touch /usr/NET/www_pub/hdd_10min.txt
        hdd=`cat /usr/NET/www_pub/hdd_10min.txt`
        #write
        hdd=$hdd1,$hdd2;
        echo $hdd >> /usr/NET/www_pub/hdd_10min.txt
    else
	hdd=`cat /usr/NET/www_pub/hdd_10min.txt`
    fi    
fi

#NUMBER OF ALL AND HTTP CONNECTIONS
conn=`netstat -n | grep 127.0.0.1| sed -n '$='`
connhttp=`netstat -n | grep 127.0.0.1.80 | sed -n '$='`
   
traf=`/usr/local/bin/ifstat -i eth0 -q 1 1 | tail -n 1 | awk '{printf("%.2f,%.2f",$1,$2)}'`


# MEMORY
mem=`top -n | grep Mem`
            
# Active
name=`echo $mem | awk '{print $2}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Active=`echo "scale=1;$name1/1024" | bc`
else
    Active=`echo $name | tr -d 'M'`
fi;

# Inact
name=`echo $mem | awk '{print $4}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Inact=`echo "scale=1;$name1/1024" | bc`
else
    Inact=`echo $name | tr -d 'M'`
fi;

# Wired
name=`echo $mem | awk '{print $6}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Wired=`echo "scale=1;$name1/1024" | bc`
else
    Wired=`echo $name | tr -d 'M'`
fi;

# Cache
name=`echo $mem | awk '{print $8}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Cache=`echo "scale=1;$name1/1024" | bc`
else
    Cache=`echo $name | tr -d 'M'`
fi;

# Buf
name=`echo $mem | awk '{print $10}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Buf=`echo "scale=1;$name1/1024" | bc`
else
    Buf=`echo $name | tr -d 'M'`
fi;

# Free
name=`echo $mem | awk '{print $12}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Free=`echo "scale=1;$name1/1024" | bc`
else
    Free=`echo $name | tr -d 'M'`
fi;

### SWAP
swap=`top -n | grep Swap `

# Used
name=`echo $swap | awk '{print $4}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    Used=`echo "scale=1;$name1/1024" | bc`
else
    Used=`echo $name | tr -d 'M'`
fi;

# Free
name=`echo $swap | awk '{print $6}'`

if [ "$(echo $name | tail -c 2)" == "K" ] ;then
    name1=`echo $name | tr -d 'K'`
    FreeSwap=`echo "scale=1;$name1/1024" | bc`
else
    FreeSwap=`echo $name | tr -d 'M'`
fi;

mem=$Active","$Inact","$Wired","$Cache","$Buf","$Free
swap=$Used","$FreeSwap

# PROCESSES
proc=`top -n | sed -n 2p | awk '{printf("%.f,%.f", $1,$3)}'`

        
        
#WRITING TO CSV FILES
touch loads.csv
cat loads.csv | tail -10080 > newloads.csv
echo $datetime,$loads>> newloads.csv
mv newloads.csv loads.csv

touch temps.csv
cat temps.csv | tail -10080 > newtemps.csv
echo $datetime$temps,$hdd >> newtemps.csv
mv newtemps.csv temps.csv

touch conns.csv
cat conns.csv | tail -10080 > newconns.csv
echo $datetime,$conn,$connhttp >> newconns.csv
mv newconns.csv conns.csv

touch trafs.csv
cat trafs.csv | tail -10080 > newtrafs.csv
echo $datetime,$traf >> newtrafs.csv
mv newtrafs.csv trafs.csv

touch mems.csv
cat mems.csv | tail -10080 > newmems.csv
echo $datetime,$mem,$swap >> newmems.csv
mv newmems.csv mems.csv

touch procs.csv
cat procs.csv | tail -10080 > newprocs.csv
echo $datetime,$proc >> newprocs.csv
mv newprocs.csv procs.csv
