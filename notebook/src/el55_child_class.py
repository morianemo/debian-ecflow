#!/usr/bin/env python3
""" a dedicated class to communicate with ecFlow server """
import os
import signal
import sys
from ecflow import Client
# import ecf as ec
MICRO = "$$"  # double dollar to please ecFlow micro character balance


class Child(object):
    """ kid = Child(); kid.report("complete")
        this does nothing when script is called from command line    """

    def __init__(self):
        env = {"ECF_NODE": "$ECF_NODE$", "ECF_PASS": "$ECF_PASS$",
               "ECF_NAME": "$ECF_NAME$", "ECF_PORT": "$ECF_PORT$",
               "ECF_TRYNO": "$ECF_TRYNO$", }
        if MICRO[0] in env["ECF_PORT"]:
            self.client = None
            return
        self.client = Client()  #         self.client = ec.Client()
        self.client.set_child_timeout(20)
        self.client.set_host_port(env["ECF_NODE"], int(env["ECF_PORT"]))
        self.client.set_child_pid(os.getpid())
        self.client.set_child_path(env["ECF_NAME"])
        self.client.set_child_password(env["ECF_PASS"])
        self.client.set_child_try_no(int(env["ECF_TRYNO"]))
        self.report("init")
        for sig in (signal.SIGINT, signal.SIGHUP, signal.SIGQUIT,
                    signal.SIGILL, signal.SIGTRAP, signal.SIGIOT,
                    signal.SIGBUS, signal.SIGFPE, signal.SIGUSR1,
                    signal.SIGUSR2, signal.SIGPIPE, signal.SIGTERM,
                    signal.SIGXCPU, signal.SIGPWR):
            signal.signal(sig, self.signal_handler)

    def signal_handler(self, signum):
        """ catch signal """
        print('# Aborting: Signal handler called with signal ', signum)
        if self.client:
            print("# Signal handler called with signal " + str(signum))
            if signum == signal.SIGUSR2:
                self.report("complete")
            else:
                self.report("abort")

    def report(self, msg, meter=None):
        """ communicate with ecFlow server """
        print("####", msg, meter)
        if not self.client:
            if msg in("abort", ):
                pass  # raise BaseException()
            elif msg in("complete", ):
                sys.exit(0)
            # else: pass

        elif meter:
            self.client.child_meter(msg, int(meter))

        elif msg in ("init", ):
            self.client.child_init()

        elif msg in ("event", ):
            self.client.child_event("1")

        elif msg in ("abort", ):
            print("abort with report")
            self.client.child_abort()
            self.client = None
            raise BaseException()

        elif msg in("stop", "complete"):
            self.client.child_complete()
            self.client = None

        else:
            self.client.child_label("info", msg)


KID = Child()
