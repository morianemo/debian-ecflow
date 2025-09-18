#!/usr/bin/env python3
import os
import ecflow
from ecflow.ecf import (
    # Autocancel, Client, Inlimit, Limit, Node, Repeat, Today, Cron, Extern
    Defs, Suite, Family, Task, Clock, Complete, Date, Day, Defstatus, Edit,
    Event, Meter, Label, Late, Time, Trigger, Client)
ecflow.ecf.USE_LATE = True
HOME = os.getenv('HOME') + '/ecflow_server'

def create(name=os.getenv("SUITE", "elearning")):
    return Suite(name).add(
        Defstatus("suspended"),  # start immediately or not for this demo
        Clock("real"),
        Edit(ECF_INCLUDE=HOME,  # header files
             ECF_FILES=HOME,  # script template .ecf
             ECF_HOME=HOME),  # job + local output files
        Family("f1").add(
            Task("t1").add(
                Event(1),
                Label("info", ""),
                Meter("step", -1, 100)),
            Task("t2").add(
                Late("-c 01:00"),
                Meter("step", -1, 100),
                Event("a"),
                Event("b"),
                Trigger("t1:step gt 0")),
            Task("t3").add(
                Trigger("t2:a")),
            Task("t4").add(
                Complete("t2:b"),
                Trigger("t2 eq complete and not t2:b"))),
        Family("f2").add(
            Task("t1").add(
                Time("00:30 23:30 00:30")),
            Task("t2").add(
                Day("sunday")),
            Task("t3").add(
                Time("12:00"),
                Date("1.*.*")),
            Task("t4").add(
                Time("+00:02")),
            Task("t5").add(
                Time("00:02"))))


if __name__ == "__main__":
    SUITE = create()
    if True:
        import fif
        import el52_block_case as case
        import el53_block_daily as daily
        import el54_block_for as ffor
        SUITE.add(
            Family("visualise").add(
                fif.family_if(),
                case.family_case(),
                daily.process(),
                ffor.family_for()))
    DEFS = Defs()
    DEFS.add_suite(SUITE)
    CLIENT = Client(os.getenv("ECF_HOST", "localhost"),
                           os.getenv("ECF_PORT", 3141))
    DEFS.generate_scripts()
    RESULT = DEFS.simulate(); # print(RESULT)
    NODE = '/' + SUITE.name()
    CLIENT.replace("/%s" % NODE, DEFS)
