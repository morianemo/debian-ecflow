time_event() {
  task "check"
    ectime "10:00 12:00 00:10"
    event 1
  task "plot"
    trigger "check:1"
}
