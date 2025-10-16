priority() {
    limit "total" 20
    inlimit "total"
    family "slow"
    for num in $(seq 0 100); do
    family "${num}"
      task "statistics"
    endfamily
    done 
    endfamily
    family "fast"
    for num in $(seq 0 20); do
    family "${num}"
      task "plot"
    endfamily
    done
    endfamily
}

priority_limit() {
    limit "total" 20
    limit "slow" 18
    inlimit "total"

    family "slow"
    inlimit "slow"
    for num in $(seq 0 100); do    
    family "${num}"
    task "statistics"
    endfamily
    done
    
    family "fast"
    for num in $(seq 0 20); do
    family "${num}"
    task "plot"
    endfamily
    done
    endfamily
}
