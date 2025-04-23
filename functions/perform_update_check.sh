#!/usr/bin/env bash

###############################################################################
# File Name   : perform_update_check.sh                                       #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.1                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Checks the system log for the most recent full system update. If more than  #
# 7 days have passed, or if this is the first run, it prompts the user and    #
# initiates an update using 'perform_system_update'.                          #
###############################################################################

perform_update_check() {
    local update_pattern="Full system update via APT"

    if grep -q "$update_pattern" "$LOG_FILE"; then
        # Get the most recent matching entry date
        local last_entry_date
        last_entry_date=$(grep "$update_pattern" "$LOG_FILE" | tail -n 1 | awk '{print $1}')
        
        # Convert to timestamps
        local last_entry_timestamp
        last_entry_timestamp=$(date -d "$last_entry_date" +%s 2>/dev/null || echo 0)
        local current_timestamp
        current_timestamp=$(date +%s)

        local time_difference=$((current_timestamp - last_entry_timestamp))
        local seven_days=$((7 * 24 * 60 * 60))

        if [ "$last_entry_timestamp" -eq 0 ]; then
            echo -e "\n\e[1;33m[!] Warning:\e[0m Unable to parse last update date from log."
            echo -e "Proceeding with system update for safety.\n"
            log_message "WARNING" "Unable to parse update timestamp. Proceeding with update."
            perform_system_update
            return
        fi

        if [ "$time_difference" -gt "$seven_days" ]; then
            echo -e "\n\e[1;31m[!! WARNING !!]\e[0m \e[1;31mIt’s been over 7 days since the last system update\e[0m."
            echo -e "For optimal performance and security, a full update of all packages is now required.\n"
            read -n 1 -s -r -p "Press any key to begin the update..."
            echo
            log_message "INFO" "System update triggered due to time threshold (>7 days)"
            perform_system_update
        fi
    else
        # First-time run or no update log found
        echo -e "\n\e[1;32m[++ WELCOME ++]\e[0m \e[1;31mNo previous system update detected\e[0m."
        echo -e "A full update of all packages is recommended before continuing.\n"
        read -n 1 -s -r -p "Press any key to begin the update..."
        echo
        log_message "INFO" "Initial run detected – performing first full system update"
        perform_system_update
    fi
}
