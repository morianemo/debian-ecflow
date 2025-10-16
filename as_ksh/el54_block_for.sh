PARAMS="u v t r q w"

process() {
 task "process"
}

family_for() {
  family "for"
    process
    repeat integer STEP 1 240 3
  endfamily

  family "loop"
    process
    repeat string "PARAM" PARAMS
  endfamily
    
  family "parallel"
    limit "lim" 2
    inlimit "lim"
    for param in $PARAMS; do
      family $param
        edit PARAM $param
        process
        label "info" $param
      endfamily
    done
  endfamily
  family "explode"
    limit "lim" 2
    inlimit "lim"
    for num in $(seq 1 5); do 
      task t${num}
    done
  endfamily
}
