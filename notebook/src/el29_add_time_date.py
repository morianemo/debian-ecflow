#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Family, Task, Edit, Clock,
                 Time, Date, Day, Clock, Defs, Client)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Clock(False),  # "real"
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # we can add multiple variables at once
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",  # where to find script templates
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=2, ),
        Family("f2").add(
            Task("t1").add(Time("00:30 23:30 00:30")),
            Task("t2").add(Day("sunday")),
            Task("t3").add(Date("16.01.2018"),
                           Time("12:00")),
            Task("t4").add(Time("+00:02")),
            Task("t5").add(Time("00:02")))))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  sleep %SLEEP:1%; ecflow_client --meter step $STEP  # share progress
  (( STEP = STEP + 1))
done
%include <tail.h>
"""

if __name__ == '__main__':
    for task in ("t1", "t5", "t6", "t7"):  # replace all scrip templates
        with open(ECF_HOME + "/%s/%s.ecf" % (NAME, task), "w") as t:
            print(SCRIPT_TEMPLATE, file=t)
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)

    NODE = "/" + NAME  # replace top, loose f1
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
