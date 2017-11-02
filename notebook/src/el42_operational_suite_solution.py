#!/usr/bin/env python2.7
""" operational suite example """
from __future__ import print_function
import os
import ecf as ecflow
from ecf import (Defs, Defstatus, Suite, Family, Task, Variables,
                 Label, Meter, Repeat, Trigger)
HOME = os.getenv("HOME") + "/ecflow_server"
LAST_STEP = {"12": 240,
             "00": 24, }
NAME = "operational_suite"


def cycle_trigger(cyc):
    if cyc == "12":
        return Trigger("./00==complete")
    return None


DEFS = Defs()
DEFS.add(Suite(NAME).add(
    Defstatus("suspended"),  # so that jobs do not start immediately
    Repeat(kind="day", step=1),
    Variables(ECF_HOME=HOME,
              ECF_INCLUDE=HOME + "/include",
              ECF_FILES=HOME + "/files"),
    [Family(str(cycle)).add(
        Variables(CYCLE=cycle,
                  LAST_STEP=LAST_STEP[cycle]),
        cycle_trigger(cycle),

        Family("analysis").add(
            Task("get_observations"),
            Task("run_analysis").add(Trigger(["get_observations", ])),
            Task("post_processing").add(Trigger(["run_analysis", ]))),

        Family("forecast").add(
            Trigger("analysis == complete"),
            Task("get_input_data").add(Label("info", "")),
            Task("run_forecast").add(
                Trigger(["get_input_data", ]),
                Meter("step", 0, LAST_STEP[cycle]))),

        Family("archive").add(
            Family("analysis").add(
                Variables(TYPE="analysis",
                          STEP=0),
                Trigger(["../analysis/run_analysis", ]),
                Task("save"),
                [Family("step_%02d" % i).add(
                    Variables(TYPE="forecast",
                              STEP=i),
                    Trigger("../../forecast/run_forecast:step ge %d" % i),
                    Task("save"))
                 for i in range(6, LAST_STEP[cycle] + 1, 6)])))
     for cycle in ["00", "12"]]))
DEFS.generate_scripts()
RESULT = DEFS.simulate()
print(RESULT)
CLIENT = ecflow.Client(os.getenv("ECF_HOST", "localhost"),
                       os.getenv("ECF_PORT", 2500))
CLIENT.replace("/%s" % NAME, DEFS)
