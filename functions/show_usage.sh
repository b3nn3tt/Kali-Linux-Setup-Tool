#!/usr/bin/env bash

###############################################################################
# File Name   : show_usage.sh                                                 #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.2                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Displays general usage and module-specific help for the setup tool.        #
###############################################################################

show_usage() {
    echo -e "\n\e[1;33;1mUsage: $0 [OPTIONS]\e[0m"
    echo -e "\nOptions:"
    echo -e "  -a, --all           Run all options (excludes viewing logfiles)"
    echo -e "  -b, --banner        Display ASCII tool banner"
    echo -e "  -d, --desktop       Configure Custom Desktop Experience"
    echo -e "  -g, --git           Manage Git repositories (clone, edit, delete)"
    echo -e "  -h, --help          Display this help message"
    echo -e "  -l, --log           View log file"
    echo -e "  -p, --packages      Manage package installation"
    echo -e "  -s, --sudo          Configure sudo password behaviour"
    echo -e "  -v, --version       Display tool version\n"

    echo -e "\e[1;33;1mExamples:\e[0m\n"
    echo -e "Install packages from the static package list:"
    echo -e "\e[1;36m  $0 -p\e[0m or \e[1;36m$0 --packages add\e[0m\n"
    echo -e "Edit Git repositories to be cloned:"
    echo -e "\e[1;36m  $0 -g edit\e[0m or \e[1;36m$0 --git edit\e[0m\n"
    echo -e "Run both Git cloning and package installation:"
    echo -e "\e[1;36m  $0 -g -p\e[0m or \e[1;36m$0 --git clone --packages add\e[0m\n"
}

show_git_usage() {
    echo -e "\n\e[1;33m[?] Git Module Usage:\e[0m\n"
    echo -e "  -g clone  | --git clone              Clone repositories from the list"
    echo -e "  -g edit   | --git edit               Edit the repository list file"
    echo -e "  -g delete | --git delete             (Coming soon) Delete managed repositories\n"
}

show_package_usage() {
    echo -e "\n\e[1;33m[?] Package Module Usage:\e[0m\n"
    echo -e "  -p install  | --packages install     Install APT packages from the list"
    echo -e "  -p edit     | --packages edit        Edit the APT package list"
}

show_sudo_usage() {
    echo -e "\n\e[1;33m[?] Sudo Module Usage:\e[0m\n"
    echo -e "  -s status   | --sudo status          Show current sudo configuration"
    echo -e "  -s activate | --sudo activate        Enable passwordless sudo"
    echo -e "  -s disable  | --sudo disable         Disable passwordless sudo\n"
}
