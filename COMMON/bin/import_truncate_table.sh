#!/usr/bin/env bash

#main config
source "$1"
#sql config
source "$2"

#set -x

eval SQLTABLE=$SQLTABLEPATTERN;
log_debug " Truncate table $SQLDATABASE.$SQLTABLE"

rm -rf $SQLFILE
echo "TRUNCATE TABLE \`"$SQLDATABASE"\`.\`"$SQLTABLE"\`" > $SQLFILE


RS=`/opt/lampp/bin/mysql -f -h $SQLHOST -u$SQLUSER -p$SQLPASSWORD $SQLDATABASE < $SQLFILE 2>&1`
RC=$?

if [ "$RS" != "" ]; then
  echo $RS;
  err=`echo $RS | grep -o 'ERROR [0-9][0-9]*' | head -n 1 | grep -o '[0-9][0-9]*' `
  if [ "$err" != "" ]; then
    RC=$err;
  fi
fi 

if [ "$RC" = "$SQLSUCCESS" ];then
  RC=$IMPORT_SUCCESS;
else
  RC=$IMPORT_FAIL;
fi

log_debug " Truncate table $SQLDATABASE.$SQLTABLE RC=$RC - done"
exit $RC