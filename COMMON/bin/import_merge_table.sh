#!/usr/bin/env bash

#main config
source "$1"
#sql config
source "$2"

RC=0;

#set -x

log_debug " Merge table $SQLDATABASE.$SQLTABLE to $SQLDATABASE.$SQLDESTTABLE"

if [ "$SQLTABLE" = "" ];then
  eval SQLTABLE=$SQLTABLEPATTERN;
fi

if [ "$SQLDATABASE" = "" ]; then
  RC=1;
fi 

if [ "$SQLTABLE" = "" ]; then
  RC=2;
fi 

if [ "$SQLDESTTABLE" = "" ]; then
  RC=3;
fi 

if [ "$RC" = "0" ];then
    rm -rf $SQLFILE
 
cat  << EOF > $SQLFILE
REPLACE INTO \`$SQLDATABASE\`.\`$SQLDESTTABLE\` SELECT * FROM \`$SQLDATABASE\`.\`$SQLTABLE\`;
DROP TABLE \`$SQLDATABASE\`.\`$SQLTABLE\`;
EOF
    
    
    RS=`/opt/lampp/bin/mysql -h $SQLHOST -u$SQLUSER -p$SQLPASSWORD $SQLDATABASE < $SQLFILE 2>&1`
    RC=$?
    
    if [ "$RS" != "" ]; then
      #echo $RS;
      err=`echo $RS | grep -o 'ERROR [0-9][0-9]*' | head -n 1 | grep -o '[0-9][0-9]*' `
      if [ "$err" != "" ]; then
        RC=$err;
      fi
    fi 
    
    if [ "$RC" = "$SQLSUCCESS" ];then
      RC=0;
    else
      RC=4;
      log_warn "Merge table $SQLDATABASE.$SQLTABLE to $SQLDATABASE.$SQLDESTTABLE - error (RC=$RC) - SQL ERROR ($RS)";
    fi
else
    log_warn "Merge table $SQLDATABASE.$SQLTABLE to $SQLDATABASE.$SQLDESTTABLE - error (RC=$RC) - Missing configuration";
fi
log_debug " Merge table $SQLDATABASE.$SQLTABLE to $SQLDATABASE.$SQLDESTTABLE - done (RC=$RC)"
exit $RC