#!/bin/sh
# Retrieve session count from auth.log file for Prometheus
# Working directory
cd /var/lib/node_exporter

awk '
/CRON[[][0-9]*[]]: pam_unix/ { m[$11]++ }
END {
 for(k in m) {
   print "cron_log_session_count{user=\""k"\"}", m[k]
 }
}
' /var/log/auth.log > ./cron-log-session.tmp
mv ./cron-log-session.tmp ./cron-log-session.prom
