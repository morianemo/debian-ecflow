clean() {
time_range=${1} || time_range="00:00 23:59 01:00"
    task "clean"
    time $time_range
}

ex2() {
    name=$1 || name="elearning"
    HOME="${HOME}/ecflow_server"
 suite $name
    edit ECF_HOME $HOME
    edit ECF_INCLUDE $HOME/include
        repeat date "YMD" 20250101 20451212 1
        task "plot"; time "06:00"
        clean "05:00 17:00 00:30"
    }
