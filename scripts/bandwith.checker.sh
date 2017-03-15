#!/bin/bash

VERSION="Version 0.1,"
HISTORY="20170315: modified for www.joinpiggy.com"
USAGE="bandwidth.checker.sh <network interface> \n
       ./bandwidth.checker.sh eth0"

CONN=`netstat -nt | awk '{ print $5}' | cut -d: -f1 | sed -e '/^$/d' | sort -n | uniq | grep -Evi "Address|server" | wc -l`
DATE=`date '+%D | %r'`
LOG="/var/log/bandwidth.`date +'%Y%m%d'`.log"

BR1=`cat /sys/class/net/$1/statistics/rx_bytes`
BT1=`cat /sys/class/net/$1/statistics/tx_bytes`
sleep 30
BR2=`cat /sys/class/net/$1/statistics/rx_bytes`
BT2=`cat /sys/class/net/$1/statistics/tx_bytes`

INKB=$(((($BR2-$BR1) /30) /1024))
OUTKB=$(((($BT2-$BT1) /30) /1024))

echo "$DATE | $CONN | $INKB KB/s In ($1) | $OUTKB KB/s Out ($1)" >> $LOG

exit 0
