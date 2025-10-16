#!/usr/bin/env ksh
# When no arguments is specified, Client uses shell variables ECF_HOST, ECF_PORT
export ECFLOW_DEF_RESET=0
. ./setup.h # would reset DEFS
set -eux
# ecflow_start.sh would give port number 1500+uid:
$CLIENT --ping
$CLIENT --load elearning.exp
echo "# suite is now loaded"
#    print("Checking job creation: .ecf -> .job0")
#    print(Defs(DEFS).check_job_creation())
