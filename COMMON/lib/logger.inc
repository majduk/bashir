#!/usr/bin/env bash

function log_message {
  lvl=$1
  message=$2
  TRACE=1
  DEBUG=2
  INFO=3
  WARN=4
  ERROR=5
  FATAL=6
  
  eval cfg_lvl=\$$LOG_LEVEL
  eval alert_lvl=\$$ALERT_LEVEL
  if [ $cfg_lvl = "" ];then
    cfg_lvl=$INFO;  
  fi
  eval use_lvl=\$$lvl
  if [ $use_lvl = "" ];then
    uselvl=$INFO;  
  fi
  
  if [ -d $LOG_DIR ]; then
    logdir=$LOG_DIR
    logfile=$LOG_FILE
  else
    logdir=/dev
    logfile="tty"
  fi
  
  if [ $use_lvl -ge $cfg_lvl ]; then  
    echo `date $LOG_DATE_FORMAT` "$$" "$lvl" "$APP_NAME" "$message" >> $logdir/$logfile
  fi
  if [ $use_lvl -ge $alert_lvl ]; then  
    dispatch_alarm "$lvl" "$APP_NAME" "$message"
  fi  
  
}

function log_trace {
  log_message "TRACE" "$1"
}

function log_debug  {
  log_message "DEBUG" "$1"
}

function log_info {
  log_message "INFO" "$1"
}

function log_warn {
  log_message "WARN" "$1"
}

function log_error {
  log_message "ERROR" "$1"
}

function log_fatal {
  log_message "FATAL" "$1"
}

function log_stderr_redirect {
  if [ -d $LOG_DIR ]; then
    logdir=$LOG_DIR
    logfile=$LOG_FILE
  else
    logdir=/dev
    logfile="tty"
  fi
  exec >> $logdir/$logfile 2>&1 
}

function log_rotate {
  if [ -w "$LOG_DIR/$LOG_FILE" ];then
    if [ -f "$LOG_ROTATE_CONFIG" ]; then
      if [ "$LOG_ROTATE" = "" ]; then
        LOG_ROTATE="/usr/sbin/logrotate"
      fi
      if [ -x "$LOG_ROTATE" ]; then
        tmpname="$FRAMEWORK_COMMON_LOCK"/$APP_NAME.$$.$RANDOM$RANDOM$RANDOM
        echo -n "$LOG_DIR/$LOG_FILE " > $tmpname
        cat "$LOG_ROTATE_CONFIG" >> $tmpname
        "$LOG_ROTATE" --state "$LOG_DIR"/"$APP_NAME".logrotate "$tmpname" >> "$LOG_DIR/$LOG_FILE"
        rm -f "$tmpname"
      fi
    else
      echo "Log rotation unconfigured" >> "$LOG_DIR/$LOG_FILE"
    fi
  fi
}

export -f log_message
export -f log_trace
export -f log_debug
export -f log_info
export -f log_warn
export -f log_error
export -f log_fatal
export -f log_stderr_redirect
export -f log_rotate
