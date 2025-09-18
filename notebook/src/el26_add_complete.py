#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Family, Task, Edit, Trigger, Event,
                 Complete, Defs, Client)
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(  # add multiple variables at once:
            ECF_HOME=ECF_HOME,  # where job files are created by ecflow
            ECF_FILES=ECF_HOME + "/files",     # where to find script template
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
                Complete("t2:1"),
                Trigger("t2 eq complete"), ))))

if __name__ == '__main__':
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)
    NODE = "/" + NAME  # replace top
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
