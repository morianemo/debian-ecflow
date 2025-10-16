#!/usr/bin/env ksh
. ./setup.h
# ecflow_start.sh would give port number 1500 + uid:
$CLIENT --ping
$CLIENT --restart
$CLIENT --begin /${SUITE}
printf "# Suite ${SUITE} is now begun\n"
$CLIENT --resume /${SUITE}
printf "# Suite ${SUITE} is now resumed\n"

