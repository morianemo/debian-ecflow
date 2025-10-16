#!/usr/bin/env ksh
. ./setup.h
ECF_FILES=$ECF_HOME/files
suite $SUITE
        defstatus "suspended"  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_FILES  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 5  # user variable to be inherited by task/families below
        family f1
            task t1
            task t2
              trigger t1 eq complete
              event a
              event b
            task t3
              trigger t2:a
            task t4
              trigger t2 eq complete
                complete t2:b
        endfamily
        endsuite

NODE="/${SUITE}"  # top
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"
