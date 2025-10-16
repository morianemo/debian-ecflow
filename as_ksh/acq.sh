#!/usr/bin/env ksh
acq() {
     family acq
        complete acq/data eq complete
        task data
            trigger rt/wait:data
            event ready
        family rt
            complete data:ready
            wait
            event data
            cron 10:00 12:00 00:05
        task late_alert
            trigger not data:ready
            time 11:00
}
acq_nrt() {
    family "acquisition"
        complete "acq/data eq complete"
        family "rt"
            complete "data:ready or nrt eq complete"
            task "wait"
                event "data"
                cron "10:00 12:00 00:05"
        task "late"
            trigger not data:ready
            time 11:00
        family nrt
            complete data:ready
                task wait
                event data
        task data
            trigger rt/wait:data or nrt/wait:data
            event ready
}
