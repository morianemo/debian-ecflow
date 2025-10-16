process() {
  family "process"
    trigger "process ne aborted"  # STOP ASAP
    family "daily"
      task "simple"
      repeat date "YMD" 20250101 20321212
      family "decade"
        task "simple"
        label "info", "Show-Icons-Complete"
        complete "../daily:YMD % 10 ne 0"
      endfamily	
    endfamily
    family "monthly"
      task "simple"
      trigger "monthly:YM lt daily:YMD / 100 or daily eq complete"
      # repeat enumerated "YM" ["%d" % YM for YM in range(202501, 203212 + 1)
      # if (YM % 100) < 13 and (YM % 100) != 0]),
      family "odd"
        task "simple"
        complete "../monthly:YM % 2 eq 0"
      endfamily
    endfamily	
    family "yearly"
       task "simple"
         repeat integer "Y" 2025 2045
         trigger "yearly:Y lt daily:YMD / 10000 or daily eq complete"
       family "decade"
         task "simple"
         complete "(../yearly:Y % 10) ne 0"
        endfamily	 
        family "century" # 
           task "simple"
           complete "(../yearly:Y % 100) ne 0"
    endfamily	   
  endfamily
}
