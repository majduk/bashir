#!/usr/bin/env bash
#v 2.0

source "$1"
if [ "$ENABLE_DEBUG" != "" ]; then
  set -x
fi

RC=0
log_debug " SFTP to $HOST"

  #prepare commands
  test -f $DOWNLOAD_SFTP_COMMANDS && rm -f $DOWNLOAD_SFTP_COMMANDS;

  echo "cd $REMOTEDIR/" >> $DOWNLOAD_SFTP_COMMANDS
  
  if [ "$DOWNLOAD_FILE_LIST" = "" ]; then
    echo "mget $DOWNLOAD_PREFIX*" >> $DOWNLOAD_SFTP_COMMANDS
  else
    if [ -f "$DOWNLOAD_FILE_LIST" ]; then
      cat "$DOWNLOAD_FILE_LIST" | while read line; do
        echo "get $line" >> $DOWNLOAD_SFTP_COMMANDS
      done
    else
      log_warn "$DOWNLOAD_FILE_LIST not found"
      RC=1     
    fi
  fi  
  echo "bye" >> $DOWNLOAD_SFTP_COMMANDS

  if [ "$RC" != "0" ];then
    log_warn " SFTP to $HOST - error (RC=$RC)"
    exit $RC;
  fi

  cdir=`pwd`;
  cd $LOCALDIR
  cat $DOWNLOAD_SFTP_COMMANDS
  /usr/bin/sftp -b $DOWNLOAD_SFTP_COMMANDS "$USER@$HOST"
  RC=$? 
  cd $cdir;
  
log_debug " SFTP to $HOST - done (RC=$RC)"
exit $RC;