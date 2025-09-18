#!/usr/bin/env python3
# -*- coding: utf-8 -*-
import os
import sys
v = "3.12"
#for ver in ("/4.12.0", ""): sys.path.append(
#        "/usr/local/apps/ecflow%s/lib/python%s/site-packages/ecflow" % (ver, v))
sys.path.append("/usr/local/lib/python3.12/site-packages/ecflow")
from ecflow.ecf import (Suite, Family, Task, Meter, Event, Label, Defstatus,
                 Edit, Trigger, Complete, Defs, Client, Repeat)
# ecflow_start.sh # to start the server, note ECF_PORT, ECF_HOME...
########################################################################
# tasks definition, with its wrapper script, to be attached to a family:


def model(fclen=240, name="model", dependencies="acquisition"):  # leaf task
    deploy("""# task wrapper, turned into a job by ecFlow
%manual
  useful information for Operators...
%end
%comment
# comment, ... ecflow_ui Edit
%end
%nopp
# no preprocessing here
%end
ID=%ID:-1%  # model id, default value -1, -1: HRES, 0: CF, N: PF
ecflow_client --event 1  # ecflow hook: send an event
for i in $(seq 0 %FCLENGTH:240%); do  # variable with default value
  sleep %SLEEP:0%; ecflow_client --meter step $i  # share progress with ecFlow
done
ecflow_client --label info "OK"  # report a label to ecFlow""", files + name + extn)
    return Task(name).add(  # HRES
        Trigger(dependencies + " eq complete"),
        Edit(FCLENGTH=fclen),  # python variable to suite variable
        Meter("step", -1, fclen),
        Label("info", ""))


#####################################################################
# create tasks wrappers/headers for ecflow server
home = os.getenv("HOME") + "/ecflow_server"  # thanks ecflow_start.sh
files = home + "/files/"      # used to define ECF_FILES
include = home + "/include/"  # headers localtion, ECF_INCLUDE
extn = ".ecf"                 # wrappers extension
os.system("mkdir -p %s" % files)
os.system("mkdir -p %s" % include)
deployed = []
def deploy(script, pathname):
    if pathname in deployed: return  # create once
    else: deployed.append(pathname) 
    if extn in pathname:  # surround .ecf with head, tail:
        script = "%include <head.h>\n" + script + "\n%include <tail.h>"
    with open(pathname, "w") as destination:  # overwrite!
        print(script, file=destination)
        print("#MSG: created", pathname)


#####################################################################
# suite definition
acq = "acquisition"
deploy("echo acq %TASK%", files + acq + extn)  # create wrapper
post = "postproc"
deploy("ecflow_client --label info %TASK%", files + post + extn)
suite = Suite("course").add(
    Defstatus("suspended"),
    Repeat("YMD", 20180101, 20321212, kind="date"),
    Edit(ECF_HOME=home,  # jobs files are created there by ecflow
         ECF_FILES=home + "/files",  # task-wrappers location
         ECF_INCLUDE=home + "/include",  # include files location
         # ECF_OUT=home,  # output files location on remote systems, 
                          # no directory created there by ecflow...
         ECF_EXTN=extn, ),  # task wrapper extension
    Task(acq).add(Event(1)),
    Family("ensemble").add(  # ENS
        Complete(acq + ":1"),
        [Family("%02d" % num).add(
            Edit(ID=num),
            model(360, dependencies="../../" + acq))  # relative path...
         for num in range(0, 10)]),
    model(240, dependencies=acq),  # HRES
    Task(post).add(
        Trigger("model eq complete"),
        Label("info", "")))


#####################################################################
head = """#!/bin/bash
set -e # stop the shell on first error
set -u # fail when using an undefined variable
set -x # echo script lines as they are executed

# Defines the variables that are needed for any communication with ECF
export ECF_PORT=%ECF_PORT%    # The server port number
export ECF_HOST=%ECF_HOST%    # where the server is running
export ECF_NAME=%ECF_NAME%    # The name of this current task
export ECF_PASS=%ECF_PASS%    # A unique password
export ECF_TRYNO=%ECF_TRYNO%  # Current try number of the task
export ECF_RID=$$             # record the process id. Also used for
                              # zombie detection

# Define the path where to find ecflow_client
# make sure client and server use the *same* version.
# Important when there are multiple versions of ecFlow
export PATH=/usr/local/apps/ecflow/%ECF_VERSION%/bin:$PATH
export PATH=$PATH:/usr/local/apps/ecflow/bin

# Tell ecFlow we have started
ecflow_client --init=$$

# Define a error handler
ERROR() {
   set +e                      # Clear -e flag, so we don't fail
   wait                        # wait for background process to stop
   ecflow_client --abort=trap  # Notify ecFlow that something went
                               # wrong, using 'trap' as the reason
   trap 0                      # Remove the trap
   exit 0                      # End the script
}

# Trap any calls to exit and errors caught by the -e flag
trap ERROR 0

# Trap any signal that may cause the script to fail
trap '{ echo "Killed by a signal"; ERROR ; }' 1 2 3 4 5 6 7 8 10 12 13 15"""
deploy(head, include + "head.h")

#####################################################################
tail = """wait            # wait for background process to stop
ecflow_client --complete  # Notify ecFlow of a normal end
trap 0                    # Remove all traps
exit 0                    # End the shell"""
deploy(tail, include + "tail.h")

#####################################################################
# loading a node into ecflow server
defs = Defs()
defs.add_suite(suite)
HOST = os.getenv("ECF_HOST", "localhost")
PORT = os.getenv("ECF_PORT", "3141")
client = Client(HOST, PORT)
path = '/%s' % suite.name() 
client.replace(path, defs)
print("#\n#MSG: node", path, "is now replaced on", HOST, PORT)
