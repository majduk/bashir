export PROC_NUM=0
export PROC_QUEUE=""

#multithreading
function proc_enqueue {
    if [ "$PROC_MAX_NPROC" -gt 0 ];then
      mprocn=$PROC_MAX_NPROC
    else
      mprocn=20
    fi
    log_debug "Queueing job \"$1\" "
    while [ $PROC_NUM -ge $PROC_MAX_NPROC ]; do
      proc_checkqueue
      sleep 0.4
    done
    log_debug "Starting job \"$1\""    
    $1 &
    PID=$!
    export PROC_QUEUE="$PROC_QUEUE $PID"
    export PROC_NUM=$(($PROC_NUM+1))
}
 
function proc_checkqueue {
    OLDCHPROC_QUEUE=$PROC_QUEUE
    for PID in $OLDCHPROC_QUEUE
    do
        if [ ! -d /proc/$PID ] ; then
            proc_regeneratequeue # at least one PID has finished
            break
        fi
    done
}

function proc_regeneratequeue {
    OLDREPROC_QUEUE=$PROC_QUEUE
    export PROC_QUEUE=""
    export PROC_NUM=0;
    for PID in $OLDREPROC_QUEUE
    do
        if [ -d /proc/$PID  ] ; then
            export PROC_QUEUE="$PROC_QUEUE $PID"
            export PROC_NUM=$(($PROC_NUM+1))
        fi
    done
}

function proc_queue_wait {
        log_debug "Waiting for $PROC_QUEUE subprocesses to finish"
        while [ "$PROC_QUEUE" != "" ]; do
            proc_checkqueue
            sleep 0.4
        done
        log_debug "Waiting for all subprocesses to finish - done"
}

export -f proc_enqueue
export -f proc_checkqueue
export -f proc_regeneratequeue
export -f proc_queue_wait