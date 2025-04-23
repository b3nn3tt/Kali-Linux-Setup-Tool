#!/usr/bin/env bash

###############################################################################
# File Name   : perform_system_update.sh                                      #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.1                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Performs a full system-wide package update using APT. Prompts the user     #
# before proceeding, logs the event, and provides clear visual feedback.     #
###############################################################################

perform_system_update() {
    echo
    echo -e "\e[1;33m[** PROCESSING **]\e[0m A full system update will now commence.\n"
    read -n 1 -s -r -p "Press any key to continue, or Ctrl + C to abort..."
    echo

    # Execute update process
    sudo apt update && sudo apt upgrade -y

    # Log the update event
    log_message "NOTICE" "Full system update via APT"

    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Full system update complete.\n"
    sleep 2
    exit 0
}
