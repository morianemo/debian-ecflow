#!/usr/bin/env python3
""" a first suite """
import os, sys
v = "3.12"
INST = "/usr/local/apps/ecflow/lib/python%s/site-packages/ecflow:" % v
sys.path.append(INST)
INST = "/usr/local/lib/python%s/site-packages/ecflow" % v
sys.path.append(INST)
from ecflow.ecf import (Defs, Suite, Defstatus, Edit, Task)
'''
module load ecflow 
conda install ecflow -c conda-forge 
'''

print("Creating suite definition")
ECF_HOME = os.path.join(os.getenv("HOME"), "ecflow_server")
NAME = os.getenv("SUITE", "elearning")
DEFS = Defs()
DEFS.add(
    Suite(NAME).add(  # simplest suite definition
        Defstatus("suspended"),  # so that jobs do not start immediately
        Edit(ECF_HOME=ECF_HOME,  # where to find jobs + output files
             ECF_FILES=ECF_HOME + "/files",  # script template .ecf
             ECF_INCLUDE=ECF_HOME + "/include"),  # include files .h
        Task("t1")))  # a first task

if __name__ == '__main__':
    print(DEFS)
    NAME = ECF_HOME + '/' + NAME
    print("# Saving definition to file '%s.def'" % NAME)
    os.system("mkdir -p %s" % NAME)
    DEFS.save_as_defs("%s.def" % NAME)  # an external client can use it
