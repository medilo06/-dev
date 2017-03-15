#!/bin/bash

VERSION="Version 0.1,"
HISTORY="20170315: modified for www.joinpiggy.com"
USAGE="#bash check_memory_utilization.sh"

FILE="/var/log/memory_utilization.`date +'%Y%m%d'`.log"

    MEMDATA=`cat /proc/meminfo | egrep "^(MemTotal|MemFree|Cached)" | sed 's/[^0-9]\+//g' | tr '\n' '\t'`
    CPUDATA=`cat /proc/loadavg | sed 's/ .\+//'`

    if [ ! -f $FILE ]
    then
        echo "Date, CPU-usage, MemTotal, MemFree, MemCached" > $FILE
    fi

    echo -n "$(date)," >>  $FILE
    echo -n "$CPUDATA," >> $FILE
    echo -n "$MEMDATA"|awk -v OFS="," '$1=$1' >>  $FILE
