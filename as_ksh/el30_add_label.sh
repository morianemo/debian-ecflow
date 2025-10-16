#!/usr/bin/env ksh
. ./setup.h
ECF_FILES=$ECF_HOME/files
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_FILES  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 2  # user variable to be inherited by task/families below
        family f3
            task t1
                label "info" "none"
                meter "step" -1 240
         endfamily
         endsuite
SCRIPT_TEMPLATE='#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  sleep %SLEEP:1%; ecflow_client --meter step $STEP  # share progress
  msg="The date is now $(date)"
  ecflow_client --label info "$msg"
  (( STEP = STEP + 1))
done
ecflow_client --label info "job is done"
%include <tail.h>
'
for num in 1 5 6 7; do  # create task template files
    echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t${num}.ecf
done
NODE="/${SUITE}/f3"  # replace top
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"
