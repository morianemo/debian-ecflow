#!/usr/bin/env bash
ECF_HOME=$HOME/ecflow_server
HOST=${ECF_HOST:=localhost}
PORT=${ECF_PORT:=3141}
CLIENT="ecflow_client --host $HOST --port $PORT"
export SUITE=elearning
. ./suite-env.sh
DEFS=${SUITE}.exp
