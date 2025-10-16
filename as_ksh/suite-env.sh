#!/bin/ksh
# aka $HOME/.ecflowrc/ecflowrc
export ECF_PORT=${ECF_PORT:=3141} ECF_HOST=${ECF_HOST:=$(uname -n)}
CLIENT="ecflow_client --port=$ECF_PORT --host=$ECF_HOST"
alias replace="$CLIENT --replace"
alias load="$CLIENT --load"
commands="autocancel clock complete cron date day defstatus edit event family inlimit label late limit meter repeat suite task today trigger endfamily endsuite endtask extern " # keywords
[[ ${ECFLOW_DEF_RESET:=1} == 1 ]] && exec 3> ${SUITE:=test}.exp # expended def-file will be created
for fname in $commands; do eval "function ${fname} { 
echo $fname \${*} >&3; }";
done
alias time="echo time ${*} >&3"
ectime() { echo time ${*} >&3; }
