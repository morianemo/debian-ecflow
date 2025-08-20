#!/usr/bin/env python3
import os
import ecflow
from ecflow import (Defstatus, Suite, Family, Task, Edit)
print("Creating suite definition")
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = ecflow.Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(ECF_HOME=ECF_HOME,
                  ECF_FILES=ECF_HOME + "/files",
                  ECF_INCLUDE=ECF_HOME + "/include"),
        Family("f1").add(  # hosting family
            Task("t1"),    # a first task
            Task("t2"),    # a second task
        )))

if __name__ == '__main__':
    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = ecflow.Client(HOST, PORT)

    NODE = "/" + NAME  # replace suite node: add f1, delete t1 t2
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
