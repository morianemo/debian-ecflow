#!/usr/bin/env python3
from ecflow import *
""" https://software.ecmwf.int/wiki/display/ECFLOW/Acquisition+task+pattern"""
def acq(): return Family("acq").add(
        Complete("acq/data eq complete"),
        Task("data").add(
            Trigger("rt/wait:data"),
            Event("ready")),
        Family("rt").add(
            Complete("data:ready"),
            Task("wait"),
            Event("data"),
            Cron("10:00 12:00 00:05")),
        Task("late_alert").add(
            Trigger("not data:ready"),
            Time("11:00")))

def acq_nrt(): return Family("acquisition").add(
        Complete("acq/data eq complete"),
        Family("rt").add(
            Complete("data:ready or nrt eq complete"),
            Task("wait").add(
                Event("data"),
                Cron("10:00 12:00 00:05"))),
        Task("late").add(
            Trigger("not data:ready"),
            Time("11:00")),
        Family("nrt").add(
            Complete("data:ready").add(
                Task("wait"),
                Event("data"))),
        Task("data").add(
            Trigger("rt/wait:data or nrt/wait:data"),
            Event("ready")))
