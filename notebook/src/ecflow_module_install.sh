#!/usr/bin/env ksh
module load python3
module load ecflow
ecflow_server --version
ecflow_client --version
python3 -c 'import ecflow; help(ecflow.ecflow)'
