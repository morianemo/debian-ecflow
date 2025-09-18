#!/usr/bin/env python3
import os
from ecflow.ecf import (  # Autocancel, Clock, Cron, Today, Edit, Extern, Repeat
    Complete, Date, Day, Defs, Defstatus, Event, Family, InLimit, Label, Late,
    Limit, Meter, Suite, Task, Time, Trigger, Edit, Client)
HOME = os.getenv('HOME') + '/ecflow_server'


def create(name):
    """ suite provider """
    return Suite(name).add(
        Defstatus("suspended"),
        Edit(ECF_INCLUDE=HOME,  # header files
             ECF_FILES=HOME,    # script template .ecf
             ECF_HOME=HOME),    # job + local output files
        Family("f1").add(
            Task("t1").add(
                Label("info", ""),
                # Late("-c 01:00"),
                Meter("step", -1, 100)),
            Task("t2").add(
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
    NAME = os.getenv("SUITE", "elearning")
    DEFS = Defs()
    SUITE = create(NAME)
    if False:
        import ex1, ex1s, ex2, ex2s, ex3, ex4
        SUITE.add(Family("exercises").add(
            ex1.time_and_dates(),
            ex2.cron_clean(),
            ex3.time_event(),
            Family("priorityP").add(ex4.priority()),
            Family("priorityS").add(ex4.priority_limit()), ))
        DEFS.add_suite(ex2s.ex2("repeat_clean"))
    if True:
        import limit, limit2, fif, ffor, case
        import el58_produce_consume as produce
        SUITE.add(
            Family("visualise").add(
                produce.call_consumer(NAME + "/visualise"),
                limit.family_limit(),
                limit.family_limiter(),
                fif.family_if(),
                ffor.family_for(),
                case.family_case()))
    print(DEFS)
    DEFS.add_suite(SUITE)
    DEFS.generate_scripts()
    DEFS.simulate()
    CLIENT = Client(os.getenv("ECF_HOST", "localhost"),
                    os.getenv("ECF_PORT", 3141))
    CLIENT.replace("/%s" % NAME, DEFS)
