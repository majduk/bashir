#!/usr/bin/env bash

if [ -f "$1" ]; then
  source "$1"
else
  log_fatal "Failed to source config. Aborting"
  exit;
fi

if [ "$APP_LOCKFILE" = "" ]; then
   APP_LOCKFILE=$FRAMEWORK_COMMON_LOCK/$APP_NAME.lck
fi

log_debug " Application access lock $2"
case $2 in
  "aquire")    
    if [ -f "$APP_LOCKFILE" ];then
    	RC=$FRAMEWORK_COMMON_RC_NOK;
    else
    	touch "$APP_LOCKFILE";
    	if [ -f "$APP_LOCKFILE" ];then
    	 RC=$FRAMEWORK_COMMON_RC_OK;
    	else
    	 RC=$FRAMEWORK_COMMON_RC_NOK;
    	fi
    fi    
  ;;
  "release")
    if [ -f "$APP_LOCKFILE" ];then
      rm -f "$APP_LOCKFILE";
    	if [ -f "$APP_LOCKFILE" ];then
    	 RC=$FRAMEWORK_COMMON_RC_NOK;
    	else
    	 RC=$FRAMEWORK_COMMON_RC_OK;
    	fi
     fi      
  ;;
  default)
  ;;
esac
log_debug " Application access lock $2 ($RC) - done"
exit $RC
