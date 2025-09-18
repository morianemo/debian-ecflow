#!/usr/bin/env python3
""" if block as a family example """
from ecflow.ecf import (Family, Task, Event, Trigger, Complete)


def family_if():
    """ if block as a family example """
    return (
        Family("if_then_else").add(
            Task("if").add(
                Event("true")),
            Task("then").add(
                Complete("if eq complete and not if:true"),
                Trigger("if:true"), ),
            Task("else").add(
                Complete("if:true"),
                Trigger("if eq complete and not if:true"), )),
        Family("if").add(    # one script
            Task("model").add(
                Event("true"))),
        Family("then").add(
            Complete("if eq complete and not if/model:true"),
            Trigger("if/model:true"),
            Task("model")),
        Family("else").add(
            Complete("if/model:true"),
            Trigger("if eq complete and not if/model:true"),
            Task("model")),
        )

if __name__ == '__main__':
    print(family_if())
