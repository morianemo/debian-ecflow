#!/usr/bin/env ksh
printf "# Creating suite definition\n"
. ./setup.h
ECF_FILES=$ECF_HOME/files
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_FILES  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 1  # user variable to be inherited by task/families below
        family f1
            task t1; edit SLEEP 5
            task t2; edit SLEEP 7; trigger t1 eq complete
            task t3;
            task t4; trigger t1 eq complete and t2 eq complete
        endfamily
    endsuite
SCRIPT_TEMPLATE="#!%SHELL:/bin/bash%
%include <head.h>
echo 'I will now sleep for %SLEEP:1% seconds'
sleep %SLEEP:1%
%include <tail.h>
"
for num in $(seq 1 4); do  # create task template files
    echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t${num}.ecf
    NODE="/${SUITE}/f1/t${num}"  # this may be a family, a task path
    $CLIENT --replace $NODE $DEFS
    printf "# replaced node ${NODE} into $HOST $PORT\n"
done
