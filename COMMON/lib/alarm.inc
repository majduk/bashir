#!/usr/bin/env bash

function dispatch_alarm
{

  for alerttype in $ALERT_PROFILES; do
        log_trace "Sending alarm to $alerttype for $APP_NAME"
        case $alerttype in
        "SMS") send_alarm "$SMS_ALERT_PROFILE" "$1" "$2" "$3"
        ;;
        "EMAIL")  send_alarm "$EMAIL_ALERT_PROFILE" "$1" "$2" "$3"
        ;;
        "STORE") send_alarm "$STORE_ALERT_PROFILE" "$1" "$2" "$3"
        ;;
        *) send_alarm "$DEFAUL_TALERT_PROFILE" "$1" "$2" "$3"
        ;;
      esac      
  done
}

function send_alarm
{
  profile_cfg=$1
  level=$2
  app=$3
  message=$4
  alarmid=`date "+%Y%m%d%H%M%S"`
  
  if [ -f "$profile_cfg" ]; then
    source $profile_cfg
  fi
  
  for profile in $SENDPROFILES; do
    for param in $SENDPARAMS; do
      eval param_"$profile"_"$param"=\$"$profile""_""$param";
      eval val=\$param_"$profile"_"$param";
      if [ "$val" = "" ]; then
        eval param_"$profile"_"$param"=\$"DEFAULT_$param";
      fi
      eval $param=\$param_"$profile"_"$param";
      #eval dbg=\$"$param";
      #echo "$profile $param $dbg";
    done      

    log_trace "EXECUTING $SENDCOMMAND"
    eval "$SENDCOMMAND";        
  done  
}


export -f dispatch_alarm
export -f send_alarm