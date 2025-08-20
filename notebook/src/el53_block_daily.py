#!/usr/bin/env python3
""" repeat daily weekly monthly... """
from ecflow.ecf import (Family, Task, Complete, Label, Repeat, Trigger)


def process():
    """ provide 'daily' example family """
    return (
        Family("process").add(
            Trigger("process ne aborted"),  # STOP ASAP
            Family("daily").add(
                Task("simple"),
                Repeat("YMD", 20180101, 20321212, kind="date"),
                Family("decade").add(
                    Task("simple"),
                    Label("info", "Show-Icons-Complete"),
                    Complete("../daily:YMD % 10 ne 0"))),
            Family("monthly").add(
                Task("simple"),
                Trigger("monthly:YM lt daily:YMD / 100 or daily eq complete"),
                Repeat(kind="enum", name="YM",
                       start=["%d" % YM for YM in range(201801, 203212 + 1)
                              if (YM % 100) < 13 and (YM % 100) != 0]),
                Family("odd").add(
                    Task("simple"),
                    Complete("../monthly:YM % 2 eq 0"))),
            Family("yearly").add(
                Task("simple"),
                Repeat("Y", 2018, 2032, kind="integer"),
                Trigger("yearly:Y lt daily:YMD / 10000 or daily eq complete"),
                Family("decade").add(
                    Task("simple"),
                    Complete("(../yearly:Y % 10) ne 0")),
                Family("century").add(
                    Task("simple"),
                    Complete("(../yearly:Y % 100) ne 0")))))
