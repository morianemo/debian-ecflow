#!/usr/bin/env python3
import os
ECF_HOME = os.getenv("HOME") + "/ecflow_server"  # from ecflow_start.sh
ECF_FILES = ECF_HOME + "/files"
# script template file as a string:
SCRIPT_TEMPLATE = """#!/bin/bash
%include <head.h>
echo "I am part of a suite that lives in %ECF_HOME%"
%include <tail.h>
"""

if __name__ == '__main__':
    if not os.path.exists(ECF_FILES):
        os.makedirs(ECF_FILES)  # create script template files directory
    NAME = ECF_FILES + "/t1.ecf"
    with open(NAME, "w") as t1ecf:
        print(SCRIPT_TEMPLATE, file=t1ecf)
    print("The script template file is now created:", NAME)
