#!/usr/bin/env ksh
module --help 2>/dev/null && module load ecflow || :
. ./setup.h
# conda install ecflow -c conda-forge 
echo "# Creating suite definition"
ECF_HOME=$HOME/ecflow_server
suite $SUITE
        defstatus suspended # so that jobs do not start immediately
        edit ECF_HOME $ECF_HOME  # where to find jobs + output files
        edit ECF_FILES $ECF_HOME/files  # script template .ecf
        edit ECF_INCLUDE $ECF_HOME/include # include files .h
        task t1
endsuite
printf "# Saving definition to file '${SUITE}.exp'\n"
 
