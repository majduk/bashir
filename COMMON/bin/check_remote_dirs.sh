#!/bin/env bash

source "$1"

echo `date $LOGDATEFORMAT`" Checking remote directories"

ssh -q -o 'BatchMode yes' $USER@$HOST  "test -d \"$REMOTEDIR\"";
rc=$?;
if [ "$rc" = "0" ]; then 
  echo `date $LOGDATEFORMAT`" $REMOTEDIR OK" 
else
  echo `date $LOGDATEFORMAT`" $REMOTEDIR - creating directory" 
  ssh -q -o 'BatchMode yes' $USER@$HOST  "mkdir \"$REMOTEDIR\"";
  echo `date $LOGDATEFORMAT`" $REMOTEDIR - created; rc=$?"  
fi



ssh -q -o 'BatchMode yes' $USER@$HOST  "test -d \"$REMOTEBACKUPDIR\"";
rc=$?;
if [ "$rc" = "0" ]; then 
  echo `date $LOGDATEFORMAT`" $REMOTEBACKUPDIR OK" 
else
  echo `date $LOGDATEFORMAT`" $REMOTEBACKUPDIR - creating directory" 
  ssh -q -o 'BatchMode yes' $USER@$HOST  "mkdir \"$REMOTEBACKUPDIR\"";
  echo `date $LOGDATEFORMAT`" $REMOTEBACKUPDIR - created; rc=$?"  
fi


echo `date $LOGDATEFORMAT`" Checking remote directories - done"
