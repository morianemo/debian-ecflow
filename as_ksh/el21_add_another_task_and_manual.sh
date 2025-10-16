#!/usr/bin/env ksh
printf "# Creating suite definition\n"
. ./setup.h
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $$CF_HOME
        task t1  # first task
        task t2  # second task
endsuite
SCRIPT_TEMPLATE="#!%SHELL:/bin/bash%
%manual
  Manual for task t2
  Operations: if this task fails, set it to complete, report next working day
  Analyst:    Check something ...
%end
%include <head.h>
echo 'I am part of a suite that lives in %ECF_HOME%'
%include <tail.h>
%manual
  There can be multiple manual pages in the same file.
  When viewed they are simply concatenated.
%end
"
file=$ECF_HOME/files/t2.ecf
[ ! -f file ] && echo "$SCRIPT_TEMPLATE" > $file
NODE="/${SUITE}/t2"  # this may be a family, a task path
$CLIENT --replace $NODE ${DEFS}
printf "# replaced node ${NODE} into $HOST $PORT\n"
