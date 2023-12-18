#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   log_message.sh                             #
# Description: Add's events into the log file in SYSLOG   #
#              compliant format                           #
#                                                         #
###########################################################

log_message() {
    local severity=$1
    local message=$2
    local timestamp=$DTG
    local hostname=$(hostname)
    local appname=$APP # You can make this a parameter if it varies
    local pid=$$

    echo "$timestamp $hostname $appname[$pid]: $severity: $message" >> "$LOG_FILE"
}