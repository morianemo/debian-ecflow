#!/usr/bin/env python
""" if block as a family example """
from ecf import (Family, Task, Event, Complete, Trigger, )


def family_if():
    """ if block as a family example """
    return(
        Family("if_then_else").add(
            Task("if").add(
                Event(1)),
            Task("then").add(
                Trigger("if:1"),
                Complete("if==complete and not if:1")),
            Task("else").add(
                Complete("if:1"),
                Trigger("if eq complete and not if:1"))),

        Family("if").add(    # one script
            Task("model").add(
                Event(1))),
        Family("then").add(
            Trigger("if/model:1"),
            Complete("if eq complete and not if/model:1"),
            Task("model")),
        Family("else").add(
            Complete("if/model:1"),
            Trigger("if eq complete and not if/model:1"),
            Task("model")))
