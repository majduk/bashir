#!/bin/sh

source "$1"

log_debug " Cleaning backup directory $BACKUP_DIR"
RC=0

if [ -d "$BACKUP_DIR" ];then
  if [ "$LOCALBACKUPENABLE" = "1" ];then
    oldpwd=`pwd`;
    cd "$BACKUP_DIR"; 
    archive=archive_`date +%Y%m%d`.tar
    for file in $( find . -name "$DOWNLOAD_PREFIX*" );do
      tar --remove-files -uvf $archive `basename $file`
    done
    cd "$oldpwd";
    find "$BACKUP_DIR"/ -maxdepth 1 -type f -ctime +2 -exec gzip {} \;
    find "$BACKUP_DIR"/ -maxdepth 1 -type f -ctime +$REMOTEBACKUPDAYS -exec rm -f {} \;
  else
    find "$BACKUP_DIR"/ -maxdepth 1 -type f -exec rm -f {} \;
  fi
else
  log_warn "Missing directory $BACKUP_DIR"
  RC=1
fi

log_debug " Cleaning backup directory $BACKUP_DIR - done (RC=$RC)"
exit $RC

