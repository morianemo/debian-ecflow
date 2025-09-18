#!/usr/bin/env python3
""" data acquisition suite example """
import os
from ecflow.ecf import (Date, Day, Defs, Defstatus, Suite, Family, Task,
                 If,  # If attribute in use example
                 Edit, Label, Repeat, Time, Trigger, Defs, Client)
HOME = os.getenv("HOME") + "/ecflow_course"; NAME = "data_acquisition"; DEFS = Defs()
DEFS.add(Suite(NAME).add(
    Defstatus("suspended"),  # so that jobs do not start immediately
    Repeat(kind="day", step=1),
    Edit(ECF_HOME=HOME, ECF_INCLUDE=HOME, ECF_FILES=HOME + "/acq", SLEEP=2),
    [Family(city).add(
        Family("archive").add(
            [Family(obs_type).add(
                If(test=city in ("Exeter", "Toulouse", "Offenbach"), then=Time("00:00 23:00 01:00")),
                If(city in ("Washington"), Time("00:00 23:00 03:00")),
                If(city in ("Tokyo"), Time("12:00")),
                If(city in ("Melbourne"), Day("monday")),
                If(city in ("Montreal"), Date("1.*.*")),
                Task("get").add(Label("info", "")),
                Task("process").add(Trigger("get eq complete")),
                Task("store").add(Trigger("get eq complete")))
             for obs_type in ("observations", "fields", "images")]))
        for city in ("Exeter", "Toulouse", "Offenbach", "Washington",
                     "Tokyo", "Melbourne", "Montreal")]))
# print(DEFS); DEFS.generate_scripts(); 
RESULT = DEFS.simulate(); # print(RESULT)
CLIENT = Client(os.getenv("ECF_HOST", "localhost"),
                       os.getenv("ECF_PORT", 3141))
CLIENT.replace("/%s" % NAME, DEFS)
