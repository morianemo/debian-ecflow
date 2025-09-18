#!/usr/bin/env python3
""" add another task, another manual """
import os
from ecflow import (Defs, Defstatus, Suite, Edit, Task, Client)
print("Creating suite definition")
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(  # suite definition
    Suite(NAME).add(
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(ECF_HOME=ECF_HOME),
        Task("t1"),  # first task
        Task("t2"),  # second task
    ))
SCRIPT_TEMPLATE = """%manual
  Manual for task t2
  Operations: if this task fails, set it to complete, report next working day
  Analyst:    Check something ...
%end
%include <head.h>
echo "I am part of a suite that lives in %ECF_HOME%"
%include <tail.h>

%manual
  There can be multiple manual pages in the same file.
  When viewed they are simply concatenated.
%end
"""

if __name__ == '__main__':
    # create script template file
    with open(ECF_HOME + "/files/t2.ecf", "w") as t2:
        print(SCRIPT_TEMPLATE, file=t2)

    HOST = os.getenv("ECF_HOST", "localhost")
    PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
    CLIENT = Client(HOST, PORT)
    
    NODE = "/%s/t2" % NAME  # this may be a family, a task path
    CLIENT.replace(NODE, DEFS)
    print("replaced node %s into" % NODE, HOST, PORT)
