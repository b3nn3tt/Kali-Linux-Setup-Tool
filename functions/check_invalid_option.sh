#!/usr/bin/env bash

###############################################################################
# File Name   : check_invalid_option.sh                                       #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 2.0                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Validates CLI options passed to the main script. If an unrecognised        #
# argument is found, this function displays an error and usage info.         #
###############################################################################

check_invalid_option() {
    local input="$1"

    # List of valid short and long-form CLI options
    local valid_options=" -a --all -b --banner -d --desktop -g --git -h --help -l --log -p --packages -s --sudo -v --version "

    # Check for single-dash short option or double-dash long option
    if [[ "$input" =~ ^-(-)?[a-zA-Z]+$ ]]; then
        if [[ "$valid_options" != *" $input "* ]]; then
            echo -e "\n\e[1;31m[!! ERROR !!]\e[0m Invalid option: \e[1m$input\e[0m"
            show_usage
            exit 1
        fi
    else
        echo -e "\n\e[1;31m[!! ERROR !!]\e[0m Invalid option format: \e[1m$input\e[0m"
        show_usage
        exit 1
    fi
}
