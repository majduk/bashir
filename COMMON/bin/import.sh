#!/usr/bin/env bash
#v 3.1
#next step is done only if previous was success

source "$1"
RC=0
log_debug " Importing data to DB from $IMPORT_DIR matching $IMPORT_PREFIX*"

in_counter=0;
fail_counter=0;

for file in $( find $IMPORT_DIR -type f -name "$IMPORT_PREFIX*" -print ); do
	INPUTFILE=`basename $file`
	
  for tool_name in $IMPORT_TOOLCHAIN; do
    eval tool=$tool_name;
    tool_config_name=$tool_name"_CONFIG" 
    eval tool_config=$tool_config_name;
    
    $tool "$1" "$tool_config" "$IMPORT_DIR/$INPUTFILE"
    rc=$?;
    if [ "$rc" != "$IMPORT_SUCCESS" ];then
      fail_counter=`expr "$fail_counter" + "1"` ;
      break;
    fi    
  done	
	in_counter=`expr "$in_counter" + "1"` ;
done

log_info " Imported $in_counter files with $fail_counter errors"

if [ "$in_counter" -gt 0 ];then
  if [ "$fail_counter" -ge "$in_counter" ];then
    log_warn "Too many errors: $fail_counter errors importing $in_counter files"
    RC=1
  fi
else
  if [ "$IMPORT_ALLOW_NO_FILES" != "1" ];then
    log_warn "No files to import"
    RC=1
  else
    log_info "No files to import"
    RC=0   
  fi  
fi


log_debug " Import CDRs to DB - done (RC=$RC)"
exit $RC
