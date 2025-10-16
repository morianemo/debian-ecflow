#!/usr/bin/env ksh
. ./setup.h
ECF_FILES=$ECF_HOME/files
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_FILES  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 2  # user variable to be inherited by task/families below
        family f1
            task t1
                meter step -1 240
            task t2; trigger t1 eq complete
                           event a
                           event b
            task t3; trigger t2:a
            task t4; trigger t2:b
            task t5; trigger t1:step ge 24
            task t6; trigger t1:step ge 48
            task t7; trigger t1:step ge 120
        endfamily
     endsuite
SCRIPT_TEMPLATE='#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  ecflow_client --meter step $STEP  # share progress
  msg="The date is now $(date)"; sleep %SLEEP:1%
  STEP=$((STEP + 1))
done
%include <tail.h>
'
for num in $(seq 1 7); do  # create task template files
    echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t${num}.ecf
done
NODE="/${SUITE}"  # replace f2 family
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"
