#!/bin/bash
source suite-env.sh; ECF_HOME=$HOME/course
extern /limits:hpc
# suite limits; limit hpc 100; endsuite
suite ${SUITE:=test}
edit ECF_INCLUDE $ECF_HOME; edit ECF_FILES $ECF_HOME; # r-x
edit ECF_HOME $ECF_HOME  # rwx
  defstatus suspended; limit lim 2; inlimit lim; edit SLEEP 20
  . for.def; . if.def ; . case.def ; # . trigger.def # external def
  family f1   
    task t1; meter step -1 100; # endtask # optional
    task t2; trigger t1:step gt 0; meter step -1 100; event a; event b
    task t3; trigger t2:a
    task t4; complete t2:b; trigger "t2 eq complete and not t2:b"
  endfamily;
  family f2
    for i in $(seq 1 5); do task t$i; case $i in 1)ectime 00:30 23:30 00:30;;
    2)day sunday;; 3)ectime 12:00; date 1.*.*;; 4)ectime +00:02;; 5)ectime 00:02;;
    esac; done
# endfamily # f2 # endsuite # SUITE # not necessary at the end!
