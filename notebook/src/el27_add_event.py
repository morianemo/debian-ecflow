#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Family, Task, Edit, Trigger, Event, Defs, Client)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # add multiple variables at once:
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",      # where to find script template
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=5),
        Family("f1").add(
            Task("t1"),
            Task("t2").add(
                Trigger("t1 eq complete"),
                Event("a"),
                Event("1")),
            Task("t3").add(
                Trigger("t2:a")),
            Task("t4").add(
                Trigger("t2:1")))))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
echo "I will now sleep for %SLEEP:1% seconds"
sleep %SLEEP:1%; ecflow_client --event a  # set first event
sleep %SLEEP:!%; ecflow_client --event 1  # set a second event
sleep %SLEEP:1%;  # don't sleep too much anyway
%include <tail.h>
"""

if __name__ == '__main__':
    for task in ("t1", "t2", "t3", "t4"):  # replace all script templates
        with open(ECF_HOME + "/files/%s.ecf" % task, "w") as t:
            print(SCRIPT_TEMPLATE, file=t)
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)
    NODE = "/" + NAME  # replace top
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
