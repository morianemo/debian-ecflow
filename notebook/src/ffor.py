#!/usr/bin/env python
""" for block as a family example """
import ecf as ecflow
from ecf import (Family, Task, Inlimit, Label, Limit, Repeat, Variables)
PARAMS = ["u", "v", "t", "r", "q", "w"]


def process():
    """ provide leaf task """
    return ecflow.Task("process")


def family_for():
    """ for family """
    return (
        Family("for").add(
            process(),
            Repeat(kind="integer", name="STEP", start=1, end=240, step=3)),

        Family("loop").add(
            process(),
            Repeat("PARAM", PARAMS, kind="string")),

        Family("parallel").add(
            Limit("lim", 2), Inlimit("lim"),
            [Family(param).add(
                Variables(PARAM=param),
                process().add(
                    Label("info", param)))
             for param in PARAMS]),

        Family("explode").add(
            Limit("lim", 2),
            Inlimit("lim"),
            # LIST COMPREHENSION:
            [Task("t%d" % num) for num in range(1, 5 + 1)]))
