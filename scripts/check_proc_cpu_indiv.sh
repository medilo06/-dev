#!/bin/sh

PROGNAME=`basename $0`
VERSION="Version 0.1,"
AUTHOR="2017, John Ian Medilo"
HISTORY="20170316: modify for joinpiggy"

process=""
logfile=""

LOG_DIR='/opt/log:q!s/'


date=`date +'%H:%M:%S'`;

print_version() {
    echo "$VERSION $AUTHOR"
}

print_help() {
    print_version $PROGNAME $VERSION
    echo ""
    echo ""
    echo "$PROGNAME -p firefox [-w 10] [-c 20] [-t cpu]"
    echo ""
    echo "Options:"
    echo "  -p/--process)"
    echo "     You need to provide a string for which the ps output is then"
    echo "     then \"greped\"."
    echo "  -o/--logfile)"
    echo "     Specifiy output logfile "
    exit $ST_UK
}

while test -n "$1"; do
    case "$1" in
        -help|-h)
            print_help
            exit $ST_UK
            ;;
        --version|-v)
            print_version $PROGNAME $VERSION
            exit $ST_UK
            ;;
        --process|-p)
            process=$2
            shift
            ;;
        --logfile|-o)
            logfile=$2
            shift
            ;;
        *)
            echo "Unknown argument: $1"
            print_help
            exit $ST_UK
            ;;
        esac
    shift
done

get_vals_mem() {
    #"Size\tResid.\tShared\tData\t%"
    mem_size=`awk '{OFS=",";print $1}' /proc/$PID/statm`
    mem_resident=`awk '{OFS=",";print $2}' /proc/$PID/statm`
    mem_shared=`awk '{OFS=",";print $3}' /proc/$PID/statm`
    mem_data=`awk '{OFS=",";print $6}' /proc/$PID/statm`
    ps_mem=`/usr/bin/top -b -n 1 -p $PID | grep $process | awk '{print $10}'`
    mem_totals=`echo "${ps_mem},${mem_size},${mem_resident},${mem_shared},${mem_data}"`
}

get_cpu_top() {
    process_pid=$PID
    proccount=`echo $process_pid | wc -w`
    ps_cpu=`/usr/bin/top -b -n 1 -p $PID | grep $process | awk '{print $9}'`
    if [ -z "$ps_cpu" ]
    then
        echo "$date - Error: 'top' error"
#        exit $ST_CR
    fi
}

do_wccalc() {
    wc_target1=`echo ${ps_cpu} | awk -F \. '{print $1}'`
    wc_target2=`echo ${ps_mem} | awk -F \. '{print $1}'`
    wc_target="$wc_target1 $wc_target2"
}

do_output() {
    output="${date},${process}_${NAME},$proccount,${ps_cpu},${mem_totals}"
    if [ -z "$logfile" ] ; then
        echo $output
    else
        if [ ! -f "$logfile" ]
        then
                echo 'Time,ProcName,ProcCount,%CPUTotal,%MemTotal,MemSize,MemResident,MemShared,MemData' > $logfile
        fi
        echo $output >> $logfile
    fi
}

######################
# Script Entry Point #
######################
echo "`date +'%Y%m%d %T'`: starting chk_proc_cpu.`date +'%Y%m%d'`.csv for  $process"
while [ 1 ]
do
        procmap=`ps  -p $(/sbin/pidof $process | tr -s ' ' ',') -o pid= -o args= | perl -ne "s/^\s*(\d+)\s.*dbac\/(\S+).wcfg.*/\1=\2/g;print $_"`
        date=`date +'%H:%M:%S'`;
        logfile="proc_stat_indiv.`date +'%Y%m%d'`.csv"
        while read -a line
        do
          PID=`echo $line | cut -d '=' -f 1`;
          NAME=`echo $line | cut -d '=' -f 2`;
          get_cpu_top
          get_vals_mem
          do_wccalc
          do_output
         done <<< "$procmap"
#        # Gather every  minute
         sleep 60
done
