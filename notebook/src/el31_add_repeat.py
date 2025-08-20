#!/usr/bin/env python3
import os
from ecflow.ecf import (Defstatus, Suite, Family, Task, Edit, Label, Defs, Client, Repeat)
# RepeatDate, RepeatEnumerated, RepeatInteger)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
DEFS = Defs()
NAME = os.getenv("SUITE", "elearning")

def create_families():
    """ provider """
    return [
        Family("f4").add(
            Edit(SLEEP=2),
            # RepeatEnumerated("NAME", ["a", "b", "c", "d", "e", "f"]),
            Repeat("NAME", ["a", "b", "c", "d", "e", "f"], kind='enum'),
            Task("t1")),
        Family("f5").add(
            # RepeatDate("DATE", 20170101, 20200105),
            Repeat("DATE", 20170101, 20200105, kind='date'),
            Task("t1").add(
                # RepeatInteger("PARAM", 1, 10),
                Repeat("PARAM", 1, 10, kind='integer'),                
                Label("info", "")))
    ]

DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # we can add multiple variables at once
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",  # where to find script templates
            ECF_INCLUDE=ECF_HOME + "/include",  # where to find head.h tail.h
            SLEEP=2),
        create_families()))

SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
STEP=0
while [[ $STEP -le 240 ]] ; do
  sleep %SLEEP:1%; ecflow_client --meter step $STEP  # share progress
  msg="The date is %DATE:$(date)%. PARAM is %PARAM:% NAME is %NAME:%"
  ecflow_client --label info "$msg"
  (( STEP = STEP + 1))
done
%include <tail.h>
"""

if __name__ == '__main__':
    with open(ECF_HOME + "/files/t1.ecf", "w") as script:
        print(SCRIPT_TEMPLATE, file=script)

    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)

    NODE = "/%s/f5" % NAME  # replace top
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
