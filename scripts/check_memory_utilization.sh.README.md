NAME:  check_memory_utilization.sh 

(Analyzing memory consumption)
The script will logged memory consumption based from the time it was checked. Ideally this script should run every one (1) minutes. The average 24hrs log file size is only 82KB.

To populate log file of the script a cron job schedule should be set with below parameters:
#########################################################################################################
#   * * * * * /<SCRIPT FOLDER>/check_memory_utilization.sh                                              #
#########################################################################################################


Comparing the output: Relevant fields from /proc/meminfo to match them against the output of free -k:
#########################################################################################
#  $ grep -E "MemTotal|MemFree|Buffers|Cached|SwapTotal|SwapFree" /proc/meminfo         #
#  MemTotal:        3838776 kB                                                          #
#  MemFree:          163304 kB                                                          #
#  Buffers:          188476 kB                                                          #
#  Cached:          2934552 kB                                                          #
#  SwapCached:            0 kB                                                          #
#  SwapTotal:             0 kB                                                          #
#  SwapFree:              0 kB                                                          #
#########################################################################################
#  $free -k                                                                             #
#               total       used       free     shared    buffers     cached            #
#  Mem:       3838776    3675472     163304      39936     188476    2934552            #
#  -/+ buffers/cache:     552444    3286332                                             #
#  Swap:            0          0          0                                             #
#########################################################################################


Matching output of free -k to /proc/meminfo


The following table shows how to get the free output matched to the /proc/meminfo fields.
#####################################################################################################################
# free output                                                #  coresponding /proc/meminfo fields                   #
#####################################################################################################################
# Mem: total                                                 #  MemTotal                                            #
# Mem: used                                                  #  MemTotal - MemFree                                  #
# Mem: free                                                  #  MemFree                                             #
# Mem: shared (can be ignored nowadays. It has no meaning.)  #  N/A                                                 #
# Mem: buffers                                               #  Buffers                                             #
# Mem: cached                                                #   Cached                                             #
# -/+ buffers/cache: used                                    #   MemTotal - (MemFree + Buffers + Cached)            #
# -/+ buffers/cache: free                                    #   MemFree + Buffers + Cached                         #
# Swap: total                                                #   SwapTotal                                          #
# Swap: used                                                 #   SwapTotal - SwapFree                               #
# Swap: free                                                 #   SwapFree                                           #
#####################################################################################################################
