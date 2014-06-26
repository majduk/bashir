#!/bin/env bash

source "$1"

file="$3"

log_debug " Backup/delete $file"

if [ "$LOCALBACKUPENABLE" = "1" ];then 
  mv $file $BACKUP_DIR/
  RC=$?
else
  rm -rf $file
  RC=$?
fi

log_debug " Backup/delete $file RC=$RC - done"
exit $RC