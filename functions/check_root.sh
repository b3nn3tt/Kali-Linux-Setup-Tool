#!/usr/bin/env bash

###############################################################################
# File Name   : check_root.sh                                                 #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.1                                                           #
# GitHub      : https://github.com/InfoSec-Research/                          #
#                                                                             #
# Description :                                                               #
# Ensures the script is not executed as the root user.                        #
# Kali now defaults to a non-root user model to promote security best         #
# practices, aligning with the principle of least privilege. This script      #
# requires standard user execution and will elevate with 'sudo' where needed. #
# Running as root bypasses those protections and is therefore not permitted.  #
###############################################################################

check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "\n\e[1;31m[*] ERROR [*]\e[0m\n"
        echo -e "This script must not be run as \e[1;31mroot\e[0m.\n"
        echo -e "It is designed to operate under the principle of least privilege"
        echo -e "and will elevate with 'sudo' only when required.\n"
        echo -e "Execution has been aborted to ensure system safety.\n"
        exit 1
    fi
}
