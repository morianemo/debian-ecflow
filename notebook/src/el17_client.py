#!/usr/bin/env python3
import os
import ecflow
# When no arguments specified, uses ECF_HOST and/or ECF_PORT,
HOST = os.getenv("ECF_HOST", "localhost")
PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
KEY = HOST + ":%d" % PORT
# multiple ways to create a client:
# python -c "import ecflow; help(ecflow.Client)"
CLIENT = ecflow.Client(KEY)
try:
    CLIENT.ping()
except RuntimeError as err:
    print("#ERR: ping failed: %s" % err)
# ci.load("%s.def" % NAME)  # read definition from disk, and load into server
try:
    CLIENT.restart_server()
except RuntimeError as err:
    print("#ERR: cannot restart server", err)
NAME = os.getenv("SUITE", "elearning")
try:
    CLIENT.begin_suite("/%s" % NAME)
except RuntimeError as err:
    print("#ERR: cannot begin suite %s" % NAME, err)
# try: CLIENT.resume("/%s" % NAME)
# except RuntimeError as err: print("#ERR: cannot resume suite %s" % NAME, err)
