#!/bin/bash
INST=/usr/local/apps/ecflow
which ecflow_client || export PATH=$INST/bin:$INST/current/bin:$PATH
LIB=lib/python3.12/site-packages
export PYTHONPATH=$INST/$LIB:$INST/$LIB/ecflow:$PYTHONPATH

# SERVER
ecflow_start.sh

# CLI CLIENT
export ECF_PORT=$((1500 + $(id -u)))  # set by ecflow_start.sh, here
ecflow_client --ping  # ECF_HOST ECF_PORT from environment
ecflow_client --port $ECF_PORT --host localhost --ping  # explicit 
ecflow_client --help  # inline documentation

# GUI
ecflow_ui &  # start in background 

# PYTHON api # inline documentation, press q
# [[ $- == *i* ]] && python -c 'import ecflow;help(ecflow)'||echo 'not interactive'
# python -c 'import ecflow; help(ecflow.Client)'  # etc...
