#!/bin/bash
# aka $HOME/.ecflowrc/ecflowrc
export ECF_PORT=${ECF_PORT:=$(($(id -u)+1500))} ECF_HOST=${ECF_HOST:=$(uname -n)}
CLIENT="ecflow_client --port=$ECF_PORT --host=$ECF_HOST"
alias replace="$CLIENT --replace"
alias load="$CLIENT --load"
 
commands="autocancel clock complete cron date day defstatus edit
event family inlimit label late limit meter repeat suite task today
trigger endfamily endsuite endtask extern " # keywords
DEF=${SUITE:=suite}.def
echo "# suite definition will be writen into $DEF"
exec 3> ${DEF} # expended def-file will be created
for fname in $commands; do source /dev/stdin <<@@
$fname() { echo $fname \${*} >&3; }
@@
done
function ectime {
    echo time ${*} >&3;
}
