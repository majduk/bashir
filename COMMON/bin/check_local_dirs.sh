#!/bin/env bash

source "$1"

log_debug " Checking local directories"
RC=0
for dir in $LOCAL_DIRECTORIES_TO_CHECK; do
    if [ -d "$dir" ]; then 
      log_debug " $dir OK" 
    else
      log_info " $dir - creating directory" 
      mkdir "$dir"
      if [ "$?" != "0" ];then
        log_error "Failed to create $dir"
        RC=1
        break;
      fi 
    fi
done

log_debug " Checking local directories - done"
exit $RC;