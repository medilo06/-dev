NAME:  bandwith.checker.sh

1. The shell script will extract and count the unique Foreign Address (IP) that connects into the server.
2. To measure bytes per second or throughput on high speed network interface.

    Expected LOG OUTPUT:
    $DATE | $CONN | $INKB KB/s In (<network interface>) | $OUTKB KB/s Out (<network interface>)" >> $LOG

    Sample actual log output:
         03/15/17 | 03:46:01 PM PHT | 521 | 3019 KB/s In (eth0) | 1512 KB/s Out (eth0)
         03/15/17 | 03:47:01 PM PHT | 520 | 3143 KB/s In (eth0) | 1613 KB/s Out (eth0)
         03/15/17 | 03:48:02 PM PHT | 498 | 3153 KB/s In (eth0) | 1556 KB/s Out (eth0)
         03/15/17 | 03:49:01 PM PHT | 526 | 2753 KB/s In (eth0) | 1407 KB/s Out (eth0)
         03/15/17 | 03:50:01 PM PHT | 500 | 2975 KB/s In (eth0) | 1570 KB/s Out (eth0)



To populate log file of the script a cron job schedule should be set with below parameters:
#########################################################################################################
#   * * * * * /<SCRIPT FOLDER>/bandwith.checker.sh [network interface] >> /[LOGS FOLDER]/cron.log       #
#########################################################################################################


          /sys/class/net/eth0/statistics/rx_bytes: number of bytes received
          /sys/class/net/eth0/statistics/tx_bytes: number of bytes transmitted

NOTE: The numbers stored in the files are automatically refreshed in real-time by the kernel. 
