#!/usr/bin/env ksh
export SUITE=data_acquisition
. ./setup.h
suite $SUITE
    defstatus suspended  # so that jobs do not start immediately
    repeat day 1
    edit ECF_HOME $HOME
    edit ECF_INCLUDE $HOME
    edit ECF_FILES $HOME/acq
    edit SLEEP 2
    for city in Exeter Toulouse Offenbach Washington \
                     Tokyo Melbourne Montreal; do
    family $city
    family "archive"
    for obs_type in observations fields images; do
    family $obs_type
    case $city in
    Exeter|Toulouse|Offenbach) ectime '00:00 23:00 01:00';;
    Washington) ectime '00:00 23:00 03:00';;
    Tokyo) ectime '12:00';;
    Melbourne) day monday;;
    Montreal) date "1.*.*";;
    esac
    task get; label "info" "-"
    task process; trigger get eq complete
    task store; trigger "get eq complete"
    endfamily
    done
    endfamily
    endfamily
    done
endsuite             
$CLIENT --replace "/${SUITE}" $DEFS
