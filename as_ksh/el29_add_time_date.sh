#!/usr/bin/env ksh
. ./setup.h
ECF_FILES=$ECF_HOME/files
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_FILES  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 2  # user variable to be inherited by task/families below
        family f2
            task t1; ectime "00:30 23:30 00:30"
            task t2; day sunday
            task t3; date "16.01.2025"
                           ectime "12:00"
            task t4; ectime "+00:02"
            task t5; ectime "00:02"
        endfamily
        endsuite
SCRIPT_TEMPLATE='#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  sleep %SLEEP:1%; ecflow_client --meter step $STEP  # share progress
  (( STEP = STEP + 1))
done
%include <tail.h>
'
for num in 1 5 6 7; do  # create task template files
    echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t${num}.ecf
done
NODE="/${SUITE}/f2"  # replace f2 family
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"

