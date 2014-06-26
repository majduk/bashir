#!/usr/bin/env bash

app_name=$1
if [ "$app_name" = "" ];then
	log_fatal "No app name fpecified";
	exit 1;
fi

log_info "PS_TREE for application $app_name"

pid=`ps -ef | grep $app_name | grep -v grep | grep -v $0 | head -n1 | awk '{ print $2}'`

if [ "$pid" = ""  ];then
	log_info "$app_name not running"
else
	pstree -ap $pid
fi 
