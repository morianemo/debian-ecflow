#!/usr/bin/env ksh

family_case() {
        family case_var
            task "case"
                defstatus complete
                edit VAR 1

            task when_1
                trigger case:VAR == 1
                complete case:VAR != 1

            task when_2
                trigger case:VAR eq 2
                complete case:VAR ne 2
    endfamily
        family case_meter
            task case
                meter STEP -1 48
            task when_1
                trigger case:STEP eq 1
                complete case==complete

            task when_2
                trigger case:STEP eq 2
                complete case eq complete
    endfamily
}
