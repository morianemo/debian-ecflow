#!/usr/bin/env python3
""" back archive example """
import os
import ecflow
from ecflow.ecf import (Defs, Defstatus, Suite, Family, Task, Edit, Label,
                 Limit, Inlimit, Repeat, Trigger, Client)
HOME = os.getenv("HOME") + "/ecflow_server"
NAME = "back_archiving"; FILES = HOME + "/back"; DEFS = Defs()
DEFS.add(Suite(NAME).add(
    Defstatus("suspended"),  # so that jobs do not start immediately
    Repeat(kind="day", step=1),
    Edit(ECF_HOME=HOME, ECF_INCLUDE=HOME, ECF_FILES=FILES, SLEEP=2),
    Limit("access", 2),
    [Family(kind).add(
        Repeat("DATE", 19900101, 19950712, kind="date"),
        Edit(KIND=kind),
        Task("get_old").add(Inlimit("access"), Label("info", "")),
        Task("convert").add(Trigger("get_old == complete")),
        Task("save_new").add(Trigger("convert eq complete"))
    ) for kind in ("analysis", "forecast", "climatology", "observations", "images")]))
# print(DEFS); DEFS.generate_scripts(); 
RESULT = DEFS.simulate(); print(RESULT)
CLIENT = Client(os.getenv("ECF_HOST", "localhost"),
                       os.getenv("ECF_PORT", 3141))
CLIENT.replace("/%s" % NAME, DEFS)
