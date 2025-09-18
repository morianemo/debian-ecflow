#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Family, Task, Edit, Trigger)
TASK3 = Task("t3")  # a python object can be set, and added later to the suite
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = ecflow.Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",      # where to find script template
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=1, ),
        Family("f1").add(
            Task("t1").add(Edit(SLEEP=5)),
            Task("t2").add(Edit(SLEEP=7),
                           Trigger("t1 eq complete")),
            TASK3,
            Task("t4").add(Trigger(["t1", "t2"])))))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
echo "I will now sleep for %SLEEP:1% seconds"; sleep %SLEEP:1%
%include <tail.h>
"""

if __name__ == '__main__':
    ecflow.USE_TRIGGER = True;  # ecflow.USE_TRIGGER = False;  # DEBUG
    for num in (1, 2, 3, 4):  # create task template files
        with open(ECF_HOME + "/files/t%d.ecf" % num, "w") as t:
            print(SCRIPT_TEMPLATE, file=t)
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = ecflow.Client(HOST, PORT)

    NODE = "/%s/f1" % NAME  # this may be a family, a task path
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
