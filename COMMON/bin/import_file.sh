#!/bin/env bash

#main config
source "$1"
#sql config
source "$2"
file="$3"

#set -x

log_debug " Import data from $file"


basen=`basename $file`
datepattern='[.][0-9]\{6\}'
#instancepattern='[.][0-9][.]' #->dla ETL comverse'a
instancepattern="" 

if [ "$FILEDATEPATTERN" != "" ]; then
  datepattern="$FILEDATEPATTERN"
fi

if [ "$FILEINSTANCEPATTERN" != "" ]; then
  instancepattern="$FILEINSTANCEPATTERN"
fi

dateprefix=`echo "$basen" | grep -o $datepattern | head -n 1 | grep -o '[0-9][0-9]*' `

if [ "$instancepattern" != "" ]; then
  instance=`echo "$basen" | grep -o $instancepattern | head -n 1  | grep -o '[0-9][0-9]*' `
else
  instance="1"
fi

#exit;
if [ "$SQLTABLE" = "" ];then
  eval SQLTABLE=$SQLTABLEPATTERN;
fi  
rm -rf $SQLFILE

#defaults:
if [ "$SQLFIELDTERMINATOR" = "" ];then
  SQLFIELDTERMINATOR=',';
fi 

if [ "$SQLONDUPLICATE" = "update" ]; then
  echo "LOAD DATA CONCURRENT LOCAL INFILE '"$file"' REPLACE INTO TABLE \`"$SQLDATABASE"\`.\`"$SQLTABLE"\` FIELDS TERMINATED BY '"$SQLFIELDTERMINATOR"'" > $SQLFILE
else
  echo "LOAD DATA CONCURRENT LOCAL INFILE '"$file"' INTO TABLE \`"$SQLDATABASE"\`.\`"$SQLTABLE"\` FIELDS TERMINATED BY '"$SQLFIELDTERMINATOR"'" > $SQLFILE
fi

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

log_debug " Import data from $file RC=$RC - done"
exit $RC
