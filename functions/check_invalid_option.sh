#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   check_invalid_option.sh                    #
# Description: Verifies the user provided option is valid #
#                                                         #
###########################################################

check_invalid_option() {
    # List of valid options (original)
    # local valid_options="-a|--all -b|--banner -d|--desktop -g|--git -h|--help -l|--logs -p|--packages -s|--sudo -v|--version"
    # List of valid options (modified)
    local valid_options=" -a --all -b --banner -d --desktop -g --git -h --help -l --log -p --packages -s --sudo -v --version "

    
    if [[ $1 =~ ^-[^-] ]]; then
        if ! [[ $valid_options =~ $1 ]]; then
            printf "Invalid option: %s\\n\\n" "$1" >&2
            usage
            exit 1
        fi
    else
        printf "Invalid option format: %s\\n" "$1" >&2
        usage
        exit 1
    fi
}