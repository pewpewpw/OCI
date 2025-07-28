#!/bin/bash
APP=/app/kibana
PID=`cat $APP/kibana.pid`
grep_process=`ps aux | grep -v grep | grep "${APP}" | grep $PID`

if [ ${#grep_process} -gt 0 ]
then
        echo "stop $APP"
        `kill ${PID}`
else
        echo "$APP is not running."
fi
