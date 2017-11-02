#!/usr/bin/env python2.7
from __future__ import print_function
import os
import ecflow
# When no arguments is specified, Client uses bash variables ECF_HOST, ECF_PORT
HOST = os.getenv("ECF_HOST", "localhost")
PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
NAME = os.getenv("SUITE", "elearning")
# ecflow_start.sh gives port number 1500+uid:
CLIENT = ecflow.Client(HOST + ":%d" % PORT)
# multiple ways to create a client:
# python -c "import ecflow; help(ecflow.Client)"
try:
    CLIENT.ping()
except RuntimeError as err:
    print("#ERR: ping failed: " + str(err))
try:  # read definition from disk and load into the server:
    CLIENT.load("%s.def" % NAME)
except RuntimeError as err:
    CLIENT.replace("/%s" % NAME, "%s.def" % NAME)
DEBUG = True  # DEBUG = False
if DEBUG:
    print("Checking job creation: .ecf -> .job0")
    print(ecflow.Defs("%s.def" % NAME).check_job_creation())
