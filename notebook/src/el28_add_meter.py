#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Family, Task, Edit, Trigger, Event,
                 Meter, Defs, Client)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # add multiple variables at once
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",     # where to find script templates
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=2),
        Family("f2").add(
            Task("t1").add(
                Meter("step", -1, 240)),
            Task("t2").add(Trigger("t1 eq complete"),
                           Event("a"),
                           Event("b")),
            Task("t3").add(Trigger("t2:a")),
            Task("t4").add(Trigger("t2:b")),
            Task("t5").add(Trigger("t1:step ge 24")),
            Task("t6").add(Trigger("t1:step ge 48")),
            Task("t7").add(Trigger("t1:step ge 120")), )))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  ecflow_client --meter step $STEP  # share progress
  msg="The date is now $(date)"; sleep %SLEEP:1%
  (( STEP = STEP + 1))
done
%include <tail.h>
"""

if __name__ == '__main__':
    for num in range(1, 7 + 1):  # new script template
        with open(ECF_HOME + "/files/t%d.ecf" % num, "w") as t:
            print(t)
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)

    NODE = "/%s/f2" % NAME  # replace only family f2
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
