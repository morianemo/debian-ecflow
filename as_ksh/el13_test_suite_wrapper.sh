#!/usr/bin/env ksh
ECF_HOME=$HOME/ecflow_server  # from ecflow_start.sh
ECF_FILES=$ECF_HOME/files
# script template file as a string:
SCRIPT_TEMPLATE="#!%SHELL:/bin/bash%
%include <head.h>
echo 'I am part of a suite that lives in %ECF_HOME%'
%include <tail.h>
"
# [ ! -d $ECF_FILES ] &&
mkdir -p $ECF_FILES  # create script template files directory
NAME=$ECF_FILES/t1.ecf
# [ ! -f $NAME ] &&
echo "$SCRIPT_TEMPLATE" > $NAME
printf "# The script template file is now created: $NAME\n"
