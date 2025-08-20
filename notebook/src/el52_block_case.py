#!/usr/bin/env python
""" case block as a family example """
from ecflow.ecf import (Defstatus, Family, Task, Meter, Complete, Trigger, Edit)


def family_case():
    """ case block as a family example """
    return (
        Family("case_var").add(
            Task("case").add(
                Defstatus("complete"),
                Edit(VAR=1)),

            Task("when_1").add(
                Trigger("case:VAR == 1"),
                Complete("case:VAR != 1")),

            Task("when_2").add(
                Trigger("case:VAR eq 2"),
                Complete("case:VAR ne 2"))),

        Family("case_meter").add(
            Task("case").add(
                Meter("STEP", -1, 48)),
            Task("when_1").add(
                Trigger("case:STEP eq 1"),
                Complete("case==complete")),

            Task("when_2").add(
                Trigger("case:STEP eq 2"),
                Complete("case eq complete"))))
