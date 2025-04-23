#!/usr/bin/env bash

###############################################################################
# File Name   : log_message.sh                                                #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.1                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# This function logs events to the central tool log file in SYSLOG-like      #
# format. It expects global variables (DTG, LOG_FILE, APP_NAME) to be        #
# defined by the calling script. It includes metadata such as timestamp,     #
# hostname, app name, and PID.                                               #
#                                                                             #
# Usage       :                                                               #
#   log_message "INFO" "Finished installing custom packages"                 #
#                                                                             #
###############################################################################

log_message() {
    local severity="$1"
    local message="$2"
    local timestamp="$DTG"local timestamp="$(date +"%Y-%m-%d %H:%M:%S")"
    local hostname
    hostname="$(hostname)"
    local appname="$APP_NAME"
    local pid="$$"

    echo "$timestamp $hostname $appname[$pid]: $severity: $message" >> "$LOG_FILE"
}
