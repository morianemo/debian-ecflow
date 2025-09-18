#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Task, Edit)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
ECF_FILES = ECF_HOME + "/files"
NAME = os.getenv("SUITE", "elearning")
DEFS = ecflow.Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # we can add multiple variables at once
            ECF_HOME=ECF_HOME,    # where job files are created by ecflow
            ECF_FILES=ECF_FILES,  # where to find script templates .ecf
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=1,  # user variable to be inherited by task/families below
        ),
        Task("t1").add(
            Edit(SLEEP=5),  # overwriting with value 5 for task t1
        ),
        Task("t2").add(
            Edit(SLEEP=7),  # overwriting with value 7 for task t2
        )))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
echo "I will now sleep for %SLEEP:1% seconds"
sleep %SLEEP:1%
%include <tail.h>
"""

if __name__ == '__main__':
    with open(ECF_FILES + "/t1.ecf", "w") as t1:
        print(SCRIPT_TEMPLATE, file=t1)
    with open(ECF_FILES + "/t2.ecf", "w") as t2:
        print(SCRIPT_TEMPLATE, file=t2)

    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = ecflow.Client(HOST, PORT)

    NODE = "/" + NAME  # this might be a family, a task path
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
