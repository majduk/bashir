#/usr/bin/env bash

#source $1
logfile="/home/ajdukm/ETL_OMN/log/omn_loader.log*"
#logfile="/home/ajdukm/ETL_OMN_OCDR/log/omn_loader.log*"

#grep -B1 'ERROR 1146' $logfile
grep -B1 'ERROR 1146' $logfile | grep 'Import' | awk '{ print $6 }' | awk ' BEGIN { FS="/" }; { print $6 }'




