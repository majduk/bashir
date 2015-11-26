#!/usr/bin/env bash

#main config
source "$1"
#sql config
source "$2"
file="$3"

#set -x

log_debug " Import data from $file"

rm -rf $SQLFILE

#defaults:
if [ "$SQLFIELDTERMINATOR" = "" ];then
  SQLFIELDTERMINATOR=',';
fi

echo "\copy "$SQLTABLE" FROM '"$file"' DELIMITER '"$SQLFIELDTERMINATOR"' CSV header" > $SQLFILE
export PGPASSWORD=$SQLPASSWORD
RS=$( /usr/bin/psql --host $SQLHOST --user $SQLUSER $SQLDATABASE < $SQLFILE 2>&1 )
RC=$?

if [ "$RC" == "0" ]; then
  echo $RS;
  if [ "$RS" != "" ]; then
    RC="1";
  fi
fi

if [ "$RC" == "0" ];then
  RC=$IMPORT_SUCCESS;
else
  RC=$IMPORT_FAIL;
fi

log_debug " Import data from $file RC=$RC - done"
exit $RC
