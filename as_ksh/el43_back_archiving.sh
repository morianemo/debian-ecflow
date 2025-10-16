#!/usr/bin/env ksh
export SUITE=back_archive
. ./setup.h
suite $SUITE
    defstatus "suspended"  # so that jobs do not start immediately
    repeat day 1
    edit ECF_HOME $ECF_HOME
    edit ECF_INCLUDE $ECF_HOME/include
    edit ECF_FILES $ECF_FILES/files
    edit SLEEP 2
    limit access 2
    for kind in "analysis" forecast climatology observations images; do    
    family $kind
        repeat date "DATE" 19900101 19950712
        edit KIND $kind
        task get_old; inlimit "access"; label info "-"
        task convert; trigger "get_old == complete"
        task save_new; trigger "convert eq complete"
    endfamily
    done
endsuite
$CLIENT --replace "/${SUITE}" $DEFS

