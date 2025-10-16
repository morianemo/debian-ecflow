#!/usr/bin/env ksh
. ./setup.h
create_family_f5() {
 family f5
        limit l1 2
        inlimit l1
        edit SLEEP 2
    for tid in $(seq 1 10); do 
        task t$tid
    done
    endfamily
}    
suite $SUITE
  create_family_f5
endsuite
SCRIPT_TEMPLATE='#!/bin/bash
%include <head.h>
sleep %SLEEP:1%
%include <tail.h>
'
NODE="/${SUITE}/f5"  # replace f5 family
mkdir -p $ECF_HOME/$NODE
for sid in $(seq 1 10); do  # replace script templates
    echo "$SCRIPT_TEMPLATE" > $ECF_HOME/$NODE/t${sid}.ecf
done
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"

