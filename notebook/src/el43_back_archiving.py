#!/usr/bin/env python2.7
""" back archive example """
from __future__ import print_function
import os
import ecf as ecflow
from ecf import (Defs, Defstatus, Suite, Family, Task, Variables, Label,
                 Limit, Inlimit, Repeat, Trigger)
HOME = os.getenv("HOME") + "/ecflow_server"
NAME = "back_archiving"; FILES = HOME + "/back"; DEFS = Defs()
DEFS.add(Suite(NAME).add(
    Defstatus("suspended"),  # so that jobs do not start immediately
    Repeat(kind="day", step=1),
    Variables(ECF_HOME=HOME, ECF_INCLUDE=HOME, ECF_FILES=FILES, SLEEP=2),
    Limit("access", 2),
    [Family(kind).add(
        Repeat("DATE", 19900101, 19950712, kind="date"),
        Variables(KIND=kind),
        Task("get_old").add(Inlimit("access"), Label("info", "")),
        Task("convert").add(Trigger("get_old == complete")),
        Task("save_new").add(Trigger("convert eq complete"))
    ) for kind in ("analysis", "forecast", "climatology", "observations", "images")]))
# print(DEFS); DEFS.generate_scripts(); 
RESULT = DEFS.simulate(); print(RESULT)
CLIENT = ecflow.Client(os.getenv("ECF_HOST", "localhost"),
                       os.getenv("ECF_PORT", 2500))
CLIENT.replace("/%s" % NAME, DEFS)
