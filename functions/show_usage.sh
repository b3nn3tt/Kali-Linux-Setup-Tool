#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   show_usage.sh                              #
# Description: Displays how to use the tool - help        #
#                                                         #
###########################################################

show_usage() {
    #echo -e "Description: A tool to prepare Kali Linux for penetration testing.\n"
    echo -e "\n\e[1;33;1mUsage: $0 [OPTIONS]\e[0m"
    echo -e "\nOptions:"
    echo -e "  -a, --all           Run all options (excludes viewing logfiles)"
    echo -e "  -b, --banner        Display ASCII tool banner"
    echo -e "  -d, --desktop       Configure Custom Desktop Experience"
    echo -e "  -g, --git           Clone Github Repositories"
    echo -e "  -h, --help          Display this help message"
    echo -e "  -l, --log           View Logfiles"
    echo -e "  -p, --packages      Install Packages"
    echo -e "  -s, --sudo          Configure sudo to run without a password"
    echo -e "  -v, --version       Display tool version\n"
    echo -e "\e[1;33;1mExamples:\e[0m\n"
    echo -e "Install packages as defined in the static package list:"
    echo -e "\n\e[1;36m    $0 -p\e[0m\n"
    echo -e "Edit the git repositories that will be cloned:"
    echo -e "\n\e[1;36m    $0 --git edit\e[0m\n"
    echo -e "Perform git cloning and package installation:"
    echo -e "\n\e[1;36m    $0 -g -p\e[0m\n"
}
