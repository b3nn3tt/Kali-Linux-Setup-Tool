#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   create_log_files.sh                        #
# Description: Creates each log file                      #
#                                                         #
###########################################################

create_log_files(){
    
    # Check if the log directory already exists
    if [ ! -d "$LOG_DIR" ]; then
        # If the directory does not exist, create it
        echo -e "\e[1;31m[*] LOG DIRECTORY NOT FOUND [*]\e[0m\nThis appears to be the first time you have run The Kali Linux Setup Tool - creating the log directory now...\n"
        sleep 2
        mkdir -p "$LOG_DIR"
        echo -e "Log directory creation completed, and can be found in the following location:\n\n    \033[35m$LOG_DIR\033[0m\n"
        sleep 2
    fi
    
    # Creation of the log file
    if [ ! -f "$LOG_FILE" ]; then
        echo -e "\033[1;93m[* CREATING *]\033[0m Creating log file in the following location:\n\n    \033[35m$LOG_FILE\033[0m\n"
        sleep 2
        
        # Populate the header of the log file
        echo -e "*****************************************************************\n************************** SUMMARY LOG **************************\n*****************************************************************\n\n" > "$LOG_FILE"
        
        # Add the DTG - Log file created line
        log_message "INFO" "Log file created."
        
        echo -e "\033[1;32m[+ COMPLETE +]\033[0m Log file created successfully.\n"
        sleep 3
    fi    
}