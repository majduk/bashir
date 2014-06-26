#!/usr/bin/env bash

#main config
source "$1"
#sql config
source "$2"

#set -x

if [ "$SQLTABLE" = "" ];then
  eval SQLTABLE=$SQLTABLEPATTERN;
fi
log_debug " Drop table $SQLDATABASE.$SQLTABLE"

rm -rf $SQLFILE
echo "DROP TABLE IF EXISTS \`"$SQLDATABASE"\`.\`"$SQLTABLE"\`" > $SQLFILE


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
  RC=0;
else
  RC=1;
fi

log_debug " Drop table $SQLDATABASE.$SQLTABLE RC=$RC - done"
exit $RC