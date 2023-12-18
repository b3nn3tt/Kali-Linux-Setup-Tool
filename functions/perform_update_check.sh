#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   perform_update_check.sh                    #
# Description: Determines date of most recent full system #
#              update                                     #
#                                                         #
###########################################################

perform_update_check() {
    # Check for the specific update entry in the log file
    if grep -q "Full system update via APT" "$LOG_FILE"; then
        # Get the most recent entry date for the specific update
        last_entry_date=$(grep "Full system update via APT" "$LOG_FILE" | tail -n 1 | awk '{print $1}')
        last_entry_timestamp=$(date -d "$last_entry_date" +%s)
        current_timestamp=$(date +%s)
        time_difference=$((current_timestamp - last_entry_timestamp))
        
        # Check if it's been more than 7 days since the last update
        if [ "$time_difference" -gt $((7 * 24 * 60 * 60)) ]; then
            echo -e "\e[1;31m[!! WARNING !!]\e[0m It's been over 7 days since the last system update. For optimal performance and security, a full update of all packages is now required.\n"
            read -n 1 -s -r -p "Please press any key to initiate the process:"
            perform_system_update
        fi
    else
        # No entries found - assume first run
        echo -e "\e[1;32m[++ WELCOME ++]\e[0m It looks like this is the first time you have run the Kali Linux Setup Tool on your system. \nFor optimal performance and security, a full update of all packages is now required.\n"
        read -n 1 -s -r -p "Press any key to begin: "
        perform_system_update
    fi
}