#!/usr/bin/env bash
# v 3.0

#set -x

if [ -f "$FRAMEWORK_COMMON_ETC"/defaults.sh ];then
  source "$FRAMEWORK_COMMON_ETC"/defaults.sh
fi
app_config=$1
if [ -f "$app_config" ]; then
  export APP_CONFIG_DIR=`dirname $app_config`
  export APP_CONFIG_FILE=$app_config
  source "$app_config"
else
  log_fatal "Config not found: $app_config"
fi

log_rotate;
log_stderr_redirect;

if [ "$APP_NAME" = "" ]; then
  APP_NAME="$APP_CONFIG_FILE"
fi
export APP_NAME;

if [ "$APP_BIN" = "" ]; then
  APP_BIN=$FRAMEWORK_BASE/$APP_NAME/bin
fi

if [ -d "$APP_BIN" ]; then
  export PATH=$APP_BIN:$PATH  
fi

if [ "$APP_RUN_COUNT" -gt "1" ];then
  if [ "$APP_RUN_SLEEP" -le "1" ];then
    APP_RUN_SLEEP=1
  fi
  log_debug "Multirun dispatcher: $APP_RUN_COUNT times, $APP_RUN_SLEEP seconds sleep"
else
  APP_RUN_COUNT=1
  APP_RUN_SLEEP=0
fi

if [ "$APP_LOCKFILE" = "" ]; then
   APP_LOCKFILE=$FRAMEWORK_COMMON_LOCK/$APP_NAME.lck
fi

(
  #try to obtain lock
  flock -x -n 200 
  if [ $? -eq 0 ];then
    #lock aquired  
        
    #execution start
    for ((i=1; i<=$APP_RUN_COUNT; i++  )); do
        log_info " +++++++++++++++++++++++ RUN START ($i of $APP_RUN_COUNT) +++++++++++++++++++++++"
               
            APP_MAIN_TOOLCHAIN_PARAMS="EXEC OPTS IS_MANDATORY RC_OK";
            for tool in $APP_MAIN_TOOLCHAIN;do        
              for param in $APP_MAIN_TOOLCHAIN_PARAMS; do
                eval toolchain_param_"$tool"_"$param"=\$"TOOLCHAIN_$tool""_""$param";
                eval val=\$toolchain_param_"$tool"_"$param";
                if [ "$val" = "" ]; then
                  eval toolchain_param_"$tool"_"$param"=\$"TOOLCHAIN_DEFAULT_$param";
                fi
                eval $param=\$toolchain_param_"$tool"_"$param";
                eval dbg=\$"$param";
              done      
          
              eval tool_exec=\$toolchain_param_"$tool"_"EXEC"
              eval tool_opts=\$toolchain_param_"$tool"_"OPTS"
              eval tool_is_mandatory=\$toolchain_param_"$tool"_"IS_MANDATORY"
              eval tool_rc_ok=\$toolchain_param_"$tool"_"RC_OK"
              
              log_info "EXECUTING \"$tool_exec $tool_opts\""
              $tool_exec $tool_opts
              RC=$?
              if [ "$RC" != "$tool_rc_ok" ];then
                if [ "$tool_is_mandatory" = "1" ];then
                  log_fatal "Mandatory tool \"$tool\" failed with return code $RC. Aborting execution."
                  break;
                else
                  log_error "Tool \"$tool\" failed with return code $RC"
                fi 
              fi                     
            done    
        log_info " +++++++++++++++++++++++ RUN   END ($i of $APP_RUN_COUNT) +++++++++++++++++++++++"
        
        if [ "$APP_RUN_SLEEP" -gt 0 ];then
          sleep $APP_RUN_SLEEP
        fi
    done
    #execution end
  else
      log_warn "Failed to aquire lock because it is owned by PIDS $( fuser $APP_LOCKFILE )"  
  fi                                   
) 200>$APP_LOCKFILE      