#!/usr/bin/env ksh
. ./setup.h
$CLIENT --restart
$CLIENT --begin /${SUITE}
printf "# Suite ${SUITE} is now begun\n"
