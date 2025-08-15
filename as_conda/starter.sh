#!/bin/bash
ecflow_start.sh -p 3141
ecflow_client --ping

ECF_FILES=$HOME/ecflow_def
mkdir -p $ECF_FILES
DEF=$ECF_FILES/suite.def
cat > $DEF <<!!
suite started
  defstatus suspended
  edit ECF_FILES $ECF_FILES
  edit ECF_INCLUDE $ECF_FILES
  family main
    task echo
      meter step -1 100 90
      event 1
      label info ''
  endfamily
endsuite
!!
cat > $ECF_FILES/echo.ecf <<!!
#!/bin/bash

export ECF_PORT=%ECF_PORT% ECF_NAME=%ECF_NAME% ECF_HOST=%ECF_HOST% ECF_PASS=%ECF_PASS% TASk=%TASK%
export SIGNAL_LIST='1 2 3 4 5 6 7 8 11 13 15 24 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45 46 47 48 49 50 51 52 53 54 55 56 57 58 59 60 61 62 63 64'

ERROR() {
set -x
set +e
wait
trap 0 $SIGNAL_LIST

# case %SUITE% in seas4) export ECF_DEBUG_CLIENT=1;; esac
$ECFLOW_CLIENT --abort  # ORIG v TEMP:
}
trap "ERROR $?" 0 $SIGNAL_LIST       

ecflow_client --init $$
for step in $(seq -s ' ' 0 100); do
  ecflow_client --meter step $step
done
ecflow_client --event 1
ecflow_client --label info 'complete'
wait
trap 0
ecflow_client --complete
exit 0
!!
ecflow_client --replace /started $DEF
ecflow_client --begin /started
ecflow_client --resume /started 

cat $HOME/ecflow_server/*log
ecflow_ui &
echo 'servers->manage-servers->add-server docker localhost 3141'
python3 -c "import ecflow; help(ecflow)"
python3 -c "import ecflow; help(ecflow.ecflow)"
