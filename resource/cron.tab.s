# crontab for scalar
# log file aging
0 1 * * * /usr/bin/find /app/elasticsearch/logs_1 -follow -type f -cmin +43200 -name "*" -exec rm -f {} \;
0 1 * * * /usr/bin/find /app/elasticsearch/logs_2 -follow -type f -cmin +43200 -name "*" -exec rm -f {} \;
0 2 * * * /usr/bin/find /data/connectome -follow -type f -cmin +43200 -name "*" -exec rm -f {} \;
0 2 * * * /usr/bin/find /data/logstash -follow -type f -cmin +14400 -name "*" -exec rm -f {} \;
0 2 * * * /usr/bin/find /data/logstash-2 -follow -type f -cmin +14400 -name "*" -exec rm -f {} \;
0 3 * * * /bin/rm /data/*.hprof
0 3 * * 0 /bin/rm /data/logstash/debug*.txt
0 4 * * 0 /bin/rm /data/logstash-2/debug*.txt
0 3 * * * /app/aggregator/restart1.sh
0 4 * * * /app/aggregator/restart2.sh
#logstash rotate
0 0 * * * /usr/sbin/logrotate -f /app/Accessories/install/resource/logstash_rotate2
