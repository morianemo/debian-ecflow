family_if() {
  family "if_then_else"
    task "if"
      event "true"
    task "then"
       complete "if eq complete and not if:true"
       trigger if:true
    task "else"
        complete if:true
        trigger "if eq complete and not if:true"
   endfamily
   family "if"    # one script
      task "model"
        event "true"
    endfamily
    family "then"
       complete "if eq complete and not if/model:true"
       trigger "if/model:true"
        task "model"
    endfamily
    family "else"
       complete "if/model:true"
       trigger "if eq complete and not if/model:true"
       task "model"
    endfamily
}

