#!/usr/bin/env python3
import os
from ecflow import (Defstatus, Suite, Family, Task, Edit, Limit, InLimit, Defs, Client)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
DEFS = Defs()
NAME = os.getenv("SUITE", "elearning")


def create_family_f5():
    """ provider """
    return Family("f5").add(
        Limit("l1", 2),
        InLimit("l1"),
        Edit(SLEEP=2),
        [Task("t%d" % tid) for tid in range(1, 10)])


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
%include <tail.h>
"""
NODE = "/%s/f5" % NAME  # replace f5 family
if not os.path.exists(ECF_HOME + NODE):
    os.makedirs(ECF_HOME + NODE)

for sid in range(1, 10):  # replace script templates
    with open(ECF_HOME + NODE + "/t%d.ecf" % sid, "w") as script:
        print(SCRIPT_TEMPLATE, file=script)

if __name__ == '__main__':
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
