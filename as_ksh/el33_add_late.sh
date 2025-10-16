#!/usr/bin/env ksh
. ./setup.h
create_family_f5() {
family f5
    limit l1 2
    inlimit l1
    edit SLEEP 2
    for idn in $(seq 1 10); do
    task t${idn}
    late '-s 00:03 -a 00:10'
    done
endfamily
}
suite $SUITE
  create_family_f5
endsuite
SCRIPT_TEMPLATE='#!/bin/bash
%include <head.h>
sleep %SLEEP:1%
%include <tail.h>'
for num in $(seq 1 10); do  # create task template files
  echo "$SCRIPT_TEMPLATE" > $ECF_HOME/t${num}.ecf
done
NODE="/${SUITE}/f5"  # replace top
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"

