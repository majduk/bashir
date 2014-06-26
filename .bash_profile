# .bash_profile

export PS1="\u@\h \W ->"

# Framework config
export FRAMEWORK_BASE=/home/p4app
export FRAMEWORK_COMMON=$FRAMEWORK_BASE/COMMON
export FRAMEWORK_COMMON_LOG=$FRAMEWORK_COMMON/log
export FRAMEWORK_COMMON_LIB=$FRAMEWORK_COMMON/lib
export FRAMEWORK_COMMON_BIN=$FRAMEWORK_COMMON/bin
export FRAMEWORK_COMMON_LOCK=$FRAMEWORK_COMMON/lock
export FRAMEWORK_COMMON_ETC=$FRAMEWORK_COMMON/etc
export FRAMEWORK_COMMON_RC_OK=0
export FRAMEWORK_COMMON_RC_NOK=1
export PATH=$FRAMEWORK_COMMON_BIN:$PATH

# Framework services config
# LOG service
export LOG_DATE_FORMAT="+[%Y/%m/%d_%H:%M:%S]"
export LOG_DIR=/dev
export LOG_FILE="tty"
export LOG_LEVEL="DEBUG"
export LOG_ROTATE=/usr/sbin/logrotate
export LOG_ROTATE_CONFIG="$FRAMEWORK_COMMON_ETC/logrotate.cfg"

# ALERT service
export ALERT_LEVEL="ERROR" 

# SEND_SMS service
export SEND_SMS_HOST=smshost
export SEND_SMS_PORT=smsport
export SEND_SMS_USER=smsuser
export SEND_SMS_PASS=smspass

# Framework library import
for lib in $FRAMEWORK_COMMON_LIB/*.inc; do
  . $lib
done

