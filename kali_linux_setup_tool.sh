#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 3.0                                            #
# Git: https://github.com/InfoSec-Research/               #
#                                                         #
# File Name:   kali-linux-setup_tool.sh                   #
###########################################################

# Ensure script is executed in bash
if [ ! "$BASH_VERSION" ] ; then
    exec /bin/bash "$0" "$@"
fi

####################################
##### GLOBAL VARIABLES SECTION #####
####################################

# Current Date Time Group at time of execution
DTG=$(date +"%Y-%m-%d %H:%M:%S")

# Application Name and Version - used in event logging
APP="Kali Linux Setup Tool v3.0"

# Constants, and frequently used variables
BASE_DIR="$(dirname "$(readlink -f "$0")")"
FUNC_DIR=$BASE_DIR/functions
RESOURCES_DIR=$BASE_DIR/resources

# Log Files
LOG_DIR=$BASE_DIR/logs
LOG_FILE=$LOG_DIR/log.txt

#####################################
##### IMPORT REQUIRED FUNCTIONS #####
#####################################

# General Functions
for FUNC in "$FUNC_DIR"/*.sh; do
    [ -e "$FUNC" ] || break
    . "$FUNC"
done

#####################################
###### SCRIPT EXECUTION BEGINS ######
#####################################

check_root

create_log_files

perform_update_check

# Default values
clone_git=false
custom_desktop=false
git_action=false
install_packages=false
package_action=false
show_banner=false
show_version=false
sudo_pass=false
view_log=false

# Parse options
while [[ $# -gt 0 ]]; do
    
    case $1 in
        -a|--all)
            show_banner=true
            clone_git=true
            git_action="clone"
            install_packages=true
            package_action="add"
            sudo_pass=true
            custom_desktop=true
            shift
        ;;
        -b|--banner)
            show_banner=true
            shift
        ;;
        -d|--desktop)
            custom_desktop=true
            shift
        ;;
        -g|--git)
            clone_git=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                git_action="$2"
                shift 2
            else
                git_action="clone"
                shift
            fi
        ;;
        -h|--help)
            show_usage
            exit 0
        ;;
        -l|--log)
            view_log=true
            shift
        ;;
        -p|--packages)
            install_packages=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                package_action="$2"
                shift 2
            else
                package_action="add"
                shift
            fi
        ;;
        -s|--sudo)
            sudo_pass=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                sudo_action="$2"
                shift 2
            else
                package_action="status"
                shift
            fi
        ;;
        -v|--version)
            show_version=true
            shift
        ;;
        *)
            check_invalid_option "$1"
        ;;
    esac
done

# If no options are specified, display help
if [[ "$show_banner" != true && "$custom_desktop" != true && "$clone_git" != true && "$view_log" != true && "$install_packages" != true && "$sudo_pass" != true && "$show_version" != true ]]; then
    show_usage
    exit 1
fi

# Section for Banner Display
if [[ "$show_banner" = true ]]; then
    display_banner
    show_version=false
fi

# Section for managing Git Repos
if [[ "$clone_git" = true ]]; then
    if [[ -z "$git_action" ]]; then
        git_action="clone"  # Set a default action if no action is provided
    fi
    
    case "$git_action" in
        clone)
            git_import
        ;;
        edit)
            # Set the default text editor to nano (you can replace 'nano' with your preferred editor, such as vi, emacs, or mousepad)
            export editor=nano
            $editor "$BASE_DIR/repositories/repository_list"
        ;;
        delete)
            echo -e "Deleting Git Repos...\n"
            # Add logic for deleting Git repositories here
        ;;
        *)
            echo -e "Invalid git action: $git_action\n"
        ;;
    esac
    clone_git=false
fi

# Section for viewing log files
if [[ "$view_log" = true ]]; then
    less "$LOG_FILE"
    view_log=false
fi

# Section for managing Packages
if [[ "$install_packages" = true ]]; then
    if [[ -z "$package_action" ]]; then
        package_action="add"  # Set a default action if no action is provided
    fi
    
    case "$package_action" in
        add)
            package_install
        ;;
        edit)
            # Set the default text editor to nano (you can replace 'nano' with your preferred editor, such as vi, emacs, or mousepad)
            export editor=nano
            $editor "$BASE_DIR/packages/package_list"
        ;;
        edit-pip)
            export editor=nano
            $editor "$BASE_DIR/packages/pip_package_list"
        ;;
        *)
            printf "Invalid package action: %s\\n" "$package_action"
        ;;
    esac
    install_packages=false
fi

# Section for Sudo Password Configuration
if [[ "$sudo_pass" = true ]]; then
    if [[ -z "$sudo_action" ]]; then
        sudo_action="status"  # Set a default action if no action is provided
    fi
    
    case "$sudo_action" in
        status)
            sudo_status
        ;;
        activate)
            enable_sudo_pass
        ;;
        disable)
            disable_sudo_pass
        ;;
        *)
            echo -e "Invalid action: $sudo_action\n"
        ;;
    esac
    sudo_pass=false
fi

# Section for Version Check
if [[ "$show_version" = true ]]; then
    echo -e "v3.0\n"
    show_version=false
fi

# Section for Custom Desktop
if [[ "$custom_desktop" = true ]]; then
    desktop_environment_setup
    custom_desktop=false
fi

# Invalidate sudo timestamp post use
sudo -k