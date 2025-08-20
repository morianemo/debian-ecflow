#!/usr/bin/env python3
""" add late attribute """
import os
import ecflow
from ecflow.ecf import (Defs, Defstatus, Suite, Family, Task, Edit,
                 Late, Limit, InLimit, Client)
ecflow.USE_LATE = True
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
DEFS = Defs()
NAME = os.getenv("SUITE", "elearning")


def create_family_f5():
    return Family("f5").add(
        Limit("l1", 2),
        InLimit("l1"),
        Edit(SLEEP=2),
        [Task("t%d" % idn).add(
            Late("-s 00:03 -a 00:10"))
         for idn in range(1, 10)])


DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # we can add multiple variables at once
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",  # where to find script templates
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=2, ),
        create_family_f5()))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
sleep %SLEEP:1%
%include <tail.h>"""

for num in range(1, 10):  # replace script templates
    with open(ECF_HOME + "/files/t%d.ecf" % num, "w") as t:
        print(SCRIPT_TEMPLATE, file=t)

if __name__ == '__main__':
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)

    NODE = "/%s/f5" % NAME  # replace top
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
