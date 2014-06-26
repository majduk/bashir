#!/bin/sh
#v 1.2


source "$1"
if [ "$ENABLE_DEBUG" != "" ]; then
  set -x
fi

echo `date $LOGDATEFORMAT`" Cleaning remote backup directory $REMOTEBACKUPDIR for last $REMOTEBACKUPDAYS days"

if [ "$REMOTE_PACK" = "1" ]; then
  archive=archive_`date +%Y%m%d`.tar
  if [ "$BACKUP_PREFIX" = "" ]; then
    BACKUP_PREFIX="backup."  
  fi
 /usr/bin/ssh -q -o 'BatchMode yes' $USER@$HOST "find $REMOTEBACKUPDIR/ -name '$BACKUP_PREFIX*' -type f -print | xargs -i basename {} | xargs -i tar --directory $REMOTEBACKUPDIR -u -v --remove-files -f $REMOTEBACKUPDIR/$archive {}"
 /usr/bin/ssh -q -o 'BatchMode yes' $USER@$HOST "find $REMOTEBACKUPDIR/ -name '*.tar' -type f -ctime +3 -print | xargs -i gzip {}"
fi
if [ "$REMOTE_DELETE" = "1" ]; then
  /usr/bin/ssh -q -o 'BatchMode yes' $USER@$HOST "find $REMOTEBACKUPDIR/ -type f -ctime +$REMOTEBACKUPDAYS -exec rm {} \; "
 fi

echo `date $LOGDATEFORMAT`" Cleaning remote backup directory $REMOTEBACKUPDIR for last $REMOTEBACKUPDAYS days - done"


