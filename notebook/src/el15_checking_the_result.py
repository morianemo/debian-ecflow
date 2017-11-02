#!/usr/bin/env python2.7
""" ecflow client: print server content """
import os
import ecflow
HOST = os.getenv("ECF_HOST", "localhost")
PORT = int(os.getenv("ECF_PORT", "%d" % (1500 + os.getuid())))
KEY = HOST + ":%d" % PORT
# multiple ways to create CLIENT: python -c "import ecflow;help(ecflow.Client)"
CLIENT = ecflow.Client(KEY)
CLIENT.sync_local()  # get live content
ecflow.PrintStyle.set_style(ecflow.Style.STATE)  # set print style
print CLIENT.get_defs()
