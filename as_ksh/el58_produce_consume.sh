#!/usr/bin/env ksh
. ./setup.h
beg=0
fin=48
by=3

not_consumer() {
    edit CONSUME "no"
}

not_producer() {
    edit PRODUCE "no"
}

events() {
    event p;
    event c;
}

call_task() {
    name=$1
    start=$2
    stop=$3
    inc=$4
    # """ leaf task """
    task $name
        events
        edit BEG $start
        edit FIN $stop
        edit BY $inc
    if [[ $start != $stop ]]; then
        meter step -1 $stop
    fi
}

trigger() {
    expression="$*"
    # """ use a function to filter/debug/intercept """
    trigger "$expression"
}

consume1() {
    leap=$1
    leap_nb=$2
    for loop in $(seq 1 $leap_nb); do    
      family $loop
        call_task consume "%STEP%" "%STEP%" $((by * leap_nb))
        repeat integer STEP $((beg+by*(loop-1))) $fin $((by*leap_nb))
        trigger "consume:STEP lt $producer/produce:STEP or $producer/produce eq complete"
      endfamily
    done
}

consume2() {
    beg=$1
    fin=$2
    for idx in $(seq $beg $fin $by); do
      family $idx
        call_task "consume" $idx $idx $by
        edit STEP $idx
        trigger "consume:STEP lt $producer/produce:STEP or $producer/produce eq complete"
      endfamily
    done
}

call_consumer() {
    lead="/$selection/consumer/admin/leader:1"
    prod="/$selection/consumer/produce"
    family "consumer"
        defstatus "suspended"

        edit SLEEP 10
        edit PRODUCE "no"
        edit CONSUME "no"

        family "limit"
            defstatus "complete"
            limit "consume" 7
        endfamily
	    
        family "admin"
            # set manually with the GUI or alter the event 1 so
            # that producer 1 becomes leader
            # default: producer0 leads
            task "leader"
                event 1  # text this task is dummy task not designed to run
                defstatus "complete"
	endfamily
		
        edit PRODUCE "yes"  # default : task does both produce/consume
        edit CONSUME "yes"

        call_task "produce" $beg $fin $by
            # this task will do both produde/consume serially           
            label "info" "both produce and consume in one task"

        family "produce0"
            # loop inside the task, report progress with a Meter
            not_consumer
            label info "loop inside the job"
            call_task "produce" $beg $fin $by
        endfamily

        family "produce1"
            # choice is to submit a new job for each step, here        
            label "info" "loop in the suite (repeat), submit one job per step"
            not_consumer
            call_task "produce" '%STEP%' "%STEP%" $by
            repeat integer "STEP" $beg $fin $by 
        endfamily

        family "consume"
            label "info" "use ecflow_client --wait %TRIGGER% in the job"
            not_producer
            inlimit "limit:consume"
            edit CALL_WAITER 1
                 # $step will be interpreted in the job!
            edit TRIGGER"../produce:step gt consume:$step or ../produce eq complete"
            call_task "consume" $beg $fin $by
        endfamily

        family "consume0or1"
            label "info" "an event may indicate the leader to trigger from"
            not_producer
            inlimit "limit:consume"
            call_task "consume" "%STEP%" "%STEP%" $by
            repeat integer "STEP" $beg $fin $by
            trigger "($lead and (consume0or1:STEP lt ${prod}1/produce:STEP or %s==complete)) or (not $lead and (consume0or1:STEP lt ${prod}0/produce:step or ${prod}0/produce==complete))"
        endfamily

        family "consume1"
            label "info" "spread consumer in multiple families"
            not_producer
            inlimit "limit:consume"
	    # producer="."	    
            consume1 # producer=prod
        endfamily

        family "consume2"
            # change manually with the GUI the limit to reduce/increase the load
            label "info" "one family per step to consume"
            inlimit "limit:consume"
            not_producer
            consume2 $beg $fin $prod
        endfamily
endfamily
}
