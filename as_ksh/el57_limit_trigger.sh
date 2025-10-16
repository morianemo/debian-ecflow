#!/usr/bin/env ksh
. ./setup.h
family_limit() {
        family "limits"
            limit "total" 15
            limit "prio" 10
            limit "other" 20  # use dictionnary
            defstatus "complete"
        endfamily
        limit "record" 50  # record active/submit tasks
        inlimit "record"
        limit "total" 2  # limiter
        family "limit"
            defstatus "complete"
            family "prio"  # on top: submitted first
                inlimit "../limits:prio"

                for step in $(seq 0 120 3); do
		 family $step
                 task "process"
		 edit STEP step
		 endfamily
                done
            endfamily
            family "side"  # below: take remaining tokens
                 inlimit "../limits:other"
                 for step in $(seq 0 120 3); do		 
                 family $step
                   task "process"
		   edit STEP step
		 endfamily
		 done
            endfamily # side
        endfamily # limit
endfamily
}

family_limiter() {
    family limiter
      inlimit limits:total
      family limits
        limit total 10
                defstatus complete
      endfamily
      family "weaker"  # weaker is located above, not to be shadowed
                trigger "../limits:total le 10"
                for step in $(seq 0 120 3); do
                    family  "$step" 
                    task process
	              edit STEP $step
		    endfamily
                done
            family "prio"  # favourite shall not lead weaker to starve
              trigger "../limits:total le 15"
              for step in $(seq 0 120 3); do	    
                family $step
                  task "process"
	            edit STEP $step
	         endfamily
	       done
            task "alarm"
                complete "limits eq complete"
                trigger "../limiter:total gt 8"  # relative path
endfamily
}
