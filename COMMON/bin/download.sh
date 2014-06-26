#!/usr/bin/env bash
#v 2.0
#all downloaded files are backed up in remote storage so they will never be downloaded again
RC=0

if [ -f "$1" ];then
  source "$1"
else
  log_error "download.sh failed to source $1"
  exit 1
fi

if [ "$ENABLE_DEBUG" != "" ]; then
  set -x
fi
#DEFAULTS
if [ "$MAX_DOWNLOAD_FILES" = "" ];then
  MAX_DOWNLOAD_FILES=1000;
fi
if [ "$DOWNLOAD_TYPE" = "" ]; then
  DOWNLOAD_TYPE="sftp";
fi
if [ "$BACKUP_PREFIX" = "" ]; then
  BACKUP_PREFIX="backup."  
fi

log_debug " Handling CDR from $HOST"

if [ "$DOWNLOAD_FILE_LIST" = "" ]; then
  if [ "$DOWNLOAD_FIND_EXPRESSION" = "" ]; then
    log_debug " Renaming files $FILEPATTERN to $DOWNLOAD_PREFIX from $HOST"
    /usr/bin/ssh -q -o 'BatchMode yes' $USER@$HOST "find $REMOTEDIR -type f -print | head -n $MAX_DOWNLOAD_FILES | xargs -i rename $FILEPATTERN $DOWNLOAD_PREFIX {}"
    log_debug " Renaming files $FILEPATTERN to $DOWNLOAD_PREFIX from $HOST - done"
  else
    log_warn " DOWNLOAD_FIND_EXPRESSION only allowed with DOWNLOAD_FILE_LIST specified"
    RC=1
  fi
else
  if [ "$DOWNLOAD_FIND_EXPRESSION" = "" ]; then
    log_warn " No DOWNLOAD_FIND_EXPRESSION only allowed with no DOWNLOAD_FILE_LIST specified"
    RC=1
  else
    log_debug " Selecting files $DOWNLOAD_FIND_EXPRESSION to download from $HOST"
    rm -f $DOWNLOAD_FILE_LIST
    /usr/bin/ssh -q -o 'BatchMode yes' $USER@$HOST "find $REMOTEDIR $DOWNLOAD_FIND_EXPRESSION | head -n $MAX_DOWNLOAD_FILES" >> "$DOWNLOAD_FILE_LIST"
    cnt=`cat $DOWNLOAD_FILE_LIST | wc -l`
    log_info " Selected $cnt files to download" 
    log_debug " Selecting files $DOWNLOAD_FIND_EXPRESSION to download from $HOST - done"
  fi
fi

if [ "$RC" != "0" ];then
  log_debug " Handling CDR from $HOST - error (RC=$RC)"
  exit $RC;
fi
  
log_debug " Downloading CDR from $HOST ($DOWNLOAD_TYPE)"

if [ "$DOWNLOAD_TYPE" = "sftp" ];then
  sftp_download.sh $1
  RC=$?
fi

if [ "$RC" != "0" ];then
  log_debug " Downloading CDR from $HOST - error (RC=$RC)"
  exit $RC;
fi

log_debug " Downloading CDR from $HOST - done"

if [ "$REMOTEKEEP" != "1" ]; then
  echo -n "" > $TMPFILE
  for file in $( find $LOCALDIR -type f ); do
    dname=`basename $file`;
    bname=`echo $dname | sed -e s/$DOWNLOAD_PREFIX/$BACKUP_PREFIX/`
    if [ "$REMOTEBACKUPDIR" != "" ]; then
      echo "mv -f $REMOTEDIR/$dname $REMOTEDIR/$bname" >> $TMPFILE
      echo "mv -f $REMOTEDIR/$bname $REMOTEBACKUPDIR" >> $TMPFILE
    else
      echo "rm -f $REMOTEDIR/$dname" >> $TMPFILE
    fi                                          
  done
  
  log_info "CDR files in $INPUTDIR directory: "`cat $TMPFILE | wc -l`
  
  log_debug " Backing up remote CDR $REMOTEDIR->$REMOTEBACKUPDIR on $HOST"
  	/usr/bin/ssh -q -o 'BatchMode yes' $USER@$HOST < $TMPFILE
  	RC=$?
  log_debug " Backing up remote CDR $REMOTEDIR->$REMOTEBACKUPDIR on $HOST - done"
  
  rm -rf $TMPFILE
else
  log_info " Remote CDR files kept on $HOST"  
fi
log_debug " Handling CDR from $HOST - done (RC=$RC)"
exit $RC