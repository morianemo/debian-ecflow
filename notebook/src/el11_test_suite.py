#!/usr/bin/env python2.7
""" a first suite """
# from __future__ import print_function
import os, sys
if 0: # try:
    from ecf import (Defs, Suite, Defstatus, Variables, Task)
else: # except ImportError, err:
    INST = "/usr/local/apps/ecflow/lib/python2.7/site-packages/ecflow:"
    sys.path.append(INST)
    INST = "/usr/local/lib/python2.7/site-packages/ecflow"
    sys.path.append(INST)
    from ecf import (Defs, Suite, Defstatus, Variables, Task)
    if 0: raise Exception(#ERR: could not import ecf. Does the following line help?"+
        "\nexport PYTHONPATH=$PYTHONPATH:%s" % INST)

print("Creating suite definition")
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(
    Suite(NAME).add(  # simplest suite definition
        Defstatus("suspended"),  # so that jobs do not start immediately
        Variables(ECF_HOME=ECF_HOME,  # where to find jobs + output files
                  ECF_FILES=ECF_HOME + "/files",  # script template .ecf
                  ECF_INCLUDE=ECF_HOME + "/include"),  # include files .h
        Task("t1")))  # a first task

if __name__ == '__main__':
    print(DEFS)
    print("Saving definition to file '%s.def'" % NAME)
    DEFS.save_as_defs(ECF_HOME+"%s.def" % NAME)  # an external client can use it
