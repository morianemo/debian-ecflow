#!/usr/bin/env ksh
. ./setup.h
ECF_FILES=$ECF_HOME/files
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_FILES  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 1  # user variable to be inherited by task/families below

        task t1
            edit SLEEP 5  # overwriting with value 5 for task t1
        task t2
            edit SLEEP 7  # overwriting with value 7 for task t2
endsuite

SCRIPT_TEMPLATE="#!%SHELL:/bin/bash%
%include <head.h>
echo 'I will now sleep for %SLEEP:1% seconds'
sleep %SLEEP:1%
%include <tail.h>
"
echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t1.ecf
echo "$SCRIPT_TEMPLATE" > $ECF_FILES/t2.ecf
NODE="/$SUITE"  # this might be a family, a task path
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"
