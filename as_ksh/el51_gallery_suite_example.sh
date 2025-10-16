#!/usr/bin/env ksh
. ./setup.h
create() {
  family f1
    task t1
      event 1
      label info "-"
      meter "step" -1 100
    task t2
      late "-c 01:00"
      meter step -1 100
      event a
      event b
      trigger "t1:step gt 0"
    task t3
      trigger t2:a
    task t4
      complete t2:b
      trigger "t2 eq complete and not t2:b"
  endfamily
  family f2
    task t1
      time "00:30 23:30 00:30"
    task t2
      day "sunday"
    task t3
      time "12:00"
      date "1.*.*"
    task t4
      time "+00:02"
    task t5
      time "00:02"
  endfamily
}
. ./fif.sh
. ./el52_block_case.sh
. ./el53_block_daily.sh
. ./el54_block_for.sh
suite $SUITE
        defstatus suspended  # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME    # where job files are created by ecflow
        edit ECF_FILES $ECF_HOME/files  # where to find script templates .ecf
        edit ECF_INCLUDE $ECF_HOME/include  # where to find head.h tail.h
        edit SLEEP 2  # user variable to be inherited by task/families below
        create
        
        family visualise
          family_if
          family_case
          process
          family_for
        endfamily
endsuite
NODE=/$SUITE	
$CLIENT --replace $NODE $DEFS
printf "# replace<d node ${NODE} into $HOST $PORT\n"
