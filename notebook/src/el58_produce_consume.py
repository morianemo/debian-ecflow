#!/usr/bin/env python3
from ecflow.ecf import (Defstatus, Family, Task, Event, Inlimit, Label,
                 Limit, Meter, Repeat, Trigger, Edit)
beg = 0
fin = 48
by = 3


def not_consumer():
    return Edit(CONSUME="no")


def not_producer():
    return Edit(PRODUCE="no")


def events():
    return (Event("p"), Event("c"))


def call_task(name, start, stop, inc):
    """ leaf task """
    meter = None
    if start != stop:
        meter = Meter("step", -1, int(stop))

    return Task(name).add(
        events(),
        Edit(BEG=start,
             FIN=stop,
             BY=inc),
        meter)


def trigger(expression):
    """ use a function to filter/debug/intercept """
    return Trigger(expression)


def consume1(leap=1, leap_nb=3, producer="."):
    return [Family("%d" % loop).add(
        call_task("consume", "%STEP%", "%STEP%", by * leap_nb).add(
            Repeat("STEP", beg+by*(loop-1), fin, by*leap_nb, kind="integer"),
            trigger("consume:STEP lt %s1/produce:STEP" % producer +
                    " or %s1/produce eq complete" % producer)))
            for loop in range(1, leap_nb + 1)]


def consume2(beg, fin, producer="."):
    return [Family("%03d" % idx).add(
        call_task("consume", idx, idx, by).add(
            Edit(STEP=idx),
            trigger("consume:STEP lt %s1/produce:STEP" % producer +
                    " or %s1/produce eq complete" % producer)))
            for idx in range(beg, fin + 1, by)]


def call_consumer(selection):
    lead = "/%s/consumer/admin/leader:1" % selection
    prod = "/%s/consumer/produce" % selection

    return Family("consumer").add(
        Defstatus("suspended"),

        Edit(SLEEP=10,
             PRODUCE="no",
             CONSUME="no"),

        Family("limit").add(
            Defstatus("complete"),
            Limit("consume", 7),),

        Family("admin").add(
            # set manually with the GUI or alter the event 1 so
            # that producer 1 becomes leader
            # default: producer0 leads
            Task("leader").add(
                Event("1"),  # text this task is dummy task not designed to run
                Defstatus("complete"))),
        
        Edit(PRODUCE="yes",  # default : task does both produce/consume
             CONSUME="yes"),

        call_task("produce", beg, fin, by).add(
            # this task will do both produde/consume serially            
            Label("info", "both produce and consume in one task")),

        Family("produce0").add(
            # loop inside the task, report progress with a Meter
            not_consumer(),
            Label("info", "loop inside the job"),
            call_task("produce", beg, fin, by)),

        Family("produce1").add(
            # choice is to submit a new job for each step, here        
            Label("info", "loop in the suite (repeat), submit one job per step"),
            not_consumer(),
            call_task("produce", '%STEP%', "%STEP%", by).add(
                Repeat("STEP", beg, fin, by, kind="integer"))),

        Family("consume").add(
            Label("info", "use ecflow_client --wait %TRIGGER% in the job"),
            not_producer(),
            Inlimit("limit:consume"),
            Edit(CALL_WAITER=1,
                 # $step will be interpreted in the job!
                 TRIGGER="../produce:step gt consume:$step or " +
                 "../produce eq complete"),
            call_task("consume", beg, fin, by)),

        Family("consume0or1").add(
            Label("info", "an event may indicate the leader to trigger from"),
            not_producer(),
            Inlimit("limit:consume"),
            call_task("consume", "%STEP%", "%STEP%", by),
            Repeat("STEP", beg, fin, by, kind="integer"),
            trigger("(%s and (consume0or1:STEP lt %s1/produce:STEP" % (
                lead, prod) + " or %s==complete)) or " % prod +
                    "(not %s and (consume0or1:STEP lt %s0/produce:step" % (
                        lead, prod) + " or %s0/produce==complete))" % prod)),

        Family("consume1").add(
            Label("info", "spread consumer in multiple families"),
            not_producer(),
            Inlimit("limit:consume"),
            consume1(producer=prod)),

        Family("consume2").add(
            # change manually with the GUI the limit to reduce/increase the load
            Label("info", "one family per step to consume"),
            Inlimit("limit:consume"),
            not_producer(),
            consume2(beg, fin, prod)))
