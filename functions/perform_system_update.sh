#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   perform_system_update.sh                   #
# Description: Runs a system wide update via apt          #
#                                                         #
###########################################################

perform_system_update() {
    echo
    echo -e "\e[1;33;1m[** PROCESSING **]\e[0m A full system update will now commence...\n"
    read -n 1 -s -r -p " Press any key to continue, or Ctrl + C to quit"
    sudo apt update && sudo apt upgrade -y
    log_message "NOTICE" "Full system update via APT"
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Full system update complete."
    sleep 2
    exit 0
}