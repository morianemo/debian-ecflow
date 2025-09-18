#!/usr/bin/env python3
""" limit can be used in a trigger expression """
from ecflow.ecf import (Defstatus, Family, Task, 
                 InLimit, Limit, Complete, Trigger, Edit)


def family_limit():
    """ example """
    return (
        Family("limits").add(
            Limit({"total": 15,
                    "prio": 10,
                    "other": 20}),  # use dictionnary
            Defstatus("complete")),
        Limit("record", 50),  # record active/submit tasks
        Inlimit("record"),
        Limit("total", 2),  # limiter

        Family("limit").add(
            Defstatus("complete"),
            Family("prio").add(  # on top: submitted first
                InLimit("../limits:prio"),

                [Family("%03d" % step).add(
                    Task("process"), Edit(STEP=step))
                 for step in range(0, 120 + 1, 3)]),

            Family("side").add(  # below: take remaining tokens
                Inlimit("../limits:other"),
                [Family("%03d" % step).add(
                    Task("process"), Edit(STEP=step))
                 for step in range(0, 120, 3)])))


def family_limiter():
    """ alternative example """
    return (
        Family("limiter").add(
            Limit("total", 10),
            InLimit("total"),

            Task("alarm").add(
                Complete("limits eq complete"),
                Trigger("../limiter:total gt 8")),  # relative path

            Family("limits").add(
                Defstatus("complete"),

            Family("weaker").add(  # weaker is located above, not to be shadowed
                Trigger("../limiter:total le 10"),
                [Family("%03d" % step).add(
                    Task("process"), Edit(STEP=step))
                 for step in range(0, 120, 3)]),

            Family("prio").add(  # favourite shall not lead weaker to starve
                Trigger("../limiter:total le 15"),
                [Family("%03d" % step).add(
                    Task("process"), Edit(STEP=step))
                 for step in range(0, 120, 3)]))))
