#!/usr/bin/env ksh
. ./setup.h
create_families() {
    family f4
      edit SLEEP 2
      repeat enumerated "NAME" a b c d e f
      task t1
    endfamily
    family f5
      repeat date "DATE" 20250101 20320105
      task t1
        repeat integer PARAM 1 10
        label "info" "-"
    endfamily
}
    suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME  # where to find jobs + output files
        edit ECF_FILES $ECF_HOME/files  # script template .ecf
        edit ECF_INCLUDE $ECF_HOME/include # include files .h
        edit SLEEP 2
        create_families
	endsuite

SCRIPT_TEMPLATE='#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  sleep %SLEEP:1%; ecflow_client --meter step $STEP  # share progress
  msg="The date is %DATE:$(date)%. PARAM is %PARAM:% NAME is %NAME:%"
  ecflow_client --label info "$msg"
  (( STEP = STEP + 1))
done
%include <tail.h>
'
num=1
echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t${num}.ecf
NODE="/${SUITE}/f5"
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"

