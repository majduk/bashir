#!/usr/bin/env bash

function sendsms
{
  from=$1
  to=$2
  msg=$3
  
  echo `date $LOG_DATE_FORMAT` "$from" "$to" "SMS: $msg"
  
  ENCODED=$(echo -n "$msg" | \
  perl -pe's/([^-_.~A-Za-z0-9])/sprintf("%%%02X", ord($1))/seg');

  URL="http://$SEND_SMS_HOST:$SEND_SMS_PORT/cgi-bin/sendsms?username=$SEND_SMS_USER&password=$SEND_SMS_PASS&from=$from&to=$to&text=$ENCODED"

  #pobranie strony
  /usr/bin/wget \
  --output-document=/dev/null \
  --no-proxy \
  $URL   
}

export -f sendsms
