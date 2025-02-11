#!/bin/bash

# Log levels
LOG_ERROR=0
LOG_WARN=1
LOG_INFO=2
LOG_DEBUG=3

# Current log level (can be overridden by environment)
CURRENT_LOG_LEVEL=${LOG_LEVEL:-$LOG_INFO}

# Logging functions
log_error() { [ $CURRENT_LOG_LEVEL -ge $LOG_ERROR ] && echo "ERROR: $*" >&2; }
log_warn()  { [ $CURRENT_LOG_LEVEL -ge $LOG_WARN  ] && echo "WARN:  $*" >&2; }
log_info()  { [ $CURRENT_LOG_LEVEL -ge $LOG_INFO  ] && echo "INFO:  $*"; }
log_debug() { [ $CURRENT_LOG_LEVEL -ge $LOG_DEBUG ] && echo "DEBUG: $*"; }