#!/usr/bin/env bash

###############################################################################
# File Name   : create_log_files.sh                                           #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.1                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Ensures the logging directory and log file are present. If not, they are    #
# created and initialised with a standard header.                             #
###############################################################################

create_log_files() {
    # Check for log directory
    if [ ! -d "$LOG_DIR" ]; then
        echo -e "\n\e[1;31m[*] LOG DIRECTORY NOT FOUND [*]\e[0m"
        echo -e "Creating log directory at:\n\n  \033[35m$LOG_DIR\033[0m\n"
        sleep 1
        mkdir -p "$LOG_DIR"
        log_message "INFO" "Log directory created at $LOG_DIR"
    fi

        # Check for log file
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "\n\e[1;31m[*] LOG FILE NOT FOUND [*]\e[0m"
        echo -e "\033[1;93m[* CREATING *]\033[0m Creating log file at:\n\n  \033[35m$LOG_FILE\033[0m\n"
        sleep 1

        # Header block for the log file
        cat <<EOF > "$LOG_FILE"
*****************************************************************
************************** SUMMARY LOG **************************
*****************************************************************

EOF

        log_message "INFO" "Log file created."
        echo -e "\033[1;32m[+ COMPLETE +]\033[0m Log file created successfully.\n"
        sleep 1
    fi

}
