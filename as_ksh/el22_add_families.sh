#!/usr/bin/env ksh
printf "# Creating suite definition\n"
. ./setup.h
    suite $SUITE
        defstatus suspended  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME
        edit ECF_FILES $ECF_HOME/files
        edit ECF_INCLUDE $ECF_HOME/include
        family f1  # hosting family
            task t1    # a first task
            task t2    # a second task
	    endfamily
	    endsuite
	    NODE=$SUITE
$CLIENT --replace $NODE $DEFS
printf "# replaced node ${NODE} into $HOST $PORT\n"
