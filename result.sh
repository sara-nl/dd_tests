#!/bin/bash

. config

export PATH=/usr/local/bin:$PATH

tpr=0
list=`ls -1 ioread* 2>/dev/null`
nreads=0
if [ "x${list}" != "x" ]; then
    for file in ioread*
    do 
    seconds=`cat $file | grep 'bytes copied' | awk '{print $7}'`
    bytes=$FILESIZE

    if [ "x${seconds}" != "x" ]; then
        i=0
        ts=0
        for s in $seconds
        do 
           nreads=`expr $nreads + 1`
           i=`expr $i + 1`
           ts=`${PYTHON} -c "print (str($s+$ts))"`
        done
        t=`${PYTHON} -c "print (str($i*$bytes/($ts*1024*1024)))"`
        echo "read: $t"
        tpr=`${PYTHON} -c "print (str($t+$tpr))"`
    fi
    done

fi

tpw=0
list=`ls -1 iowrite* 2>/dev/null`
nwrites=0
if [ "x${list}" != "x" ]; then
    for file in iowrite*
    do
    seconds=`cat $file | grep 'bytes copied' | awk '{print $7}'`
    bytes=`cat $file | grep -m 1 'bytes copied' | awk '{print $3}'`

    if [ "x${seconds}" != "x" ]; then
        i=0
        ts=0
        for s in $seconds
        do 
           nwrites=`expr $nwrites + 1`
           i=`expr $i + 1`
           ts=`${PYTHON} -c "print (str($s+$ts))"`
        done
        t=`${PYTHON} -c "print (str($i*$bytes/($ts*1024*1024)))"`
        echo write: $t
        tpw=`${PYTHON} -c "print (str($t+$tpw))"`
    fi
    done

fi

echo $nreads files read. Avg throughput reads: $tpr MiB/s
echo $nwrites files written. Avg throughput writes: $tpw MiB/s
echo
echo sum: `${PYTHON} -c "print (str($tpr+$tpw))"` MiB/s
