#!/usr/bin/env python3
import os
from ecflow import (Defstatus, Suite, Family, Task, Edit, Label, Meter,
                 Defs, Client)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
ECF_INCLUDE = ECF_HOME + "/include"
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # we can add multiple variables at once
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",  # where to find script template
            ECF_INCLUDE=ECF_INCLUDE,  # where to find head.h tail.h
            SLEEP=2, ),
        Family("f3").add(
            Task("t1").add(
                Label("info", "none"),
                Meter("step", -1, 240)))))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  sleep %SLEEP:1%; ecflow_client --meter step $STEP  # share progress
  msg="The date is now $(date)"
  ecflow_client --label info "$msg"
  (( STEP = STEP + 1))
done
ecflow_client --label info "job's done"
%include <tail.h>
"""

if __name__ == '__main__':
    for task in ("t1", "t5", "t6", "t7"):  # replace all script templates
        with open(ECF_HOME + "/files/%s.ecf" % task, "w") as t:
            print(SCRIPT_TEMPLATE, file=t)
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)

    NODE = "/" + NAME  # replace top
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
