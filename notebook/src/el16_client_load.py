#!/usr/bin/env python3
import os
import ecflow
# When no arguments specified uses ECF_HOST and/or ECF_PORT,
# Explicitly set host and port using the same client
# For alternative argument list see ecflow.Client.set_host_port()
HOST = os.getenv("ECF_HOST", "localhost")
PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
CLIENT = ecflow.Client(HOST + ":%d" % PORT)
try:
    CLIENT.ping()
except RuntimeError as err:
    print("ping failed: " + str(err))
try:
    CLIENT.restart_server()
    print("Server was restarted")
except RuntimeError as err:
    print("Server could not be restarted")
try:
    NAME = os.getenv("SUITE", "elearning")
    CLIENT.begin_suite("/%s" % NAME)
    print("Suite %s is now begun" % NAME)
except RuntimeError as err:
    print("suite %s could not begin" % NAME)
