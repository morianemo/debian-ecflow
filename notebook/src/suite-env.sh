#!/bin/bash
# aka $HOME/.ecflowrc/ecflowrc
export ECF_PORT=$(($(id -u)+1500)) ECF_HOST=$(uname -n)
client="ecflow_client --port=$ECF_PORT --host=$ECF_HOST"
alias replace="$client --replace"
alias load="$client --load"
 
commands="autocancel clock complete cron date day defstatus edit
event family inlimit label late limit meter repeat suite task today
trigger endfamily endsuite endtask extern " # keywords
exec 3> ${SUITE:=test}.exp # expended def-file will be created
for fname in $commands; do source /dev/stdin <<@@
$fname() { echo $fname \${*} >&3; }
@@
done
alias time="echo time \${*} >&3"
