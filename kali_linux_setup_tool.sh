#!/usr/bin/env bash

###############################################################################
# Kali Linux Setup Tool v3.0                                                 #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# GitHub      : https://github.com/InfoSec-Research/                          #
###############################################################################

# Enable strict mode for robustness
set -euo pipefail
IFS=$'\n\t'

##############################
#       GLOBAL CONSTANTS     #
##############################

readonly APP_NAME="Kali Linux Setup Tool"
readonly APP_VERSION="3.0"
readonly DTG="$(date +"%Y-%m-%d %H:%M:%S")"

readonly BASE_DIR="$(dirname "$(readlink -f "$0")")"
readonly FUNC_DIR="$BASE_DIR/functions"
readonly RESOURCES_DIR="$BASE_DIR/resources"
readonly LOG_DIR="$BASE_DIR/logs"
readonly LOG_FILE="$LOG_DIR/log.txt"

mkdir -p "$FUNC_DIR" "$RESOURCES_DIR" "$LOG_DIR"

##############################
#     LOAD FUNCTION FILES    #
##############################

for FUNC_FILE in "$FUNC_DIR"/*.sh; do
    [[ -f "$FUNC_FILE" ]] && . "$FUNC_FILE"
done

##############################
#  VERIFY RUNTIME ENVIRONMENT
##############################

if [[ -z "${BASH_VERSION:-}" ]]; then
    echo "[!] This script must be run using Bash."
    exec /bin/bash "$0" "$@"
fi

##############################
#    INITIAL SANITY CHECKS   #
##############################

check_root
create_log_files
perform_update_check

##############################
#     DEFAULT FLAG STATES    #
##############################

clone_git=false
custom_desktop=false
git_action=false
install_packages=false
package_action=false
show_banner=false
show_version=false
sudo_pass=false
view_log=false

##############################
#      PARSE CLI OPTIONS     #
##############################

while [[ $# -gt 0 ]]; do
    case $1 in
        -a|--all)
            show_banner=true
            custom_desktop=true
            clone_git=true
            install_packages=true
            sudo_pass=true
            show_version=true
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
                show_git_usage
                exit 1
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
                show_package_usage
                exit 1
            fi
        ;;
        -s|--sudo)
            sudo_pass=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                sudo_action="$2"
                shift 2
            else
                show_sudo_usage
                exit 1
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

##############################
#    DISPLAY USAGE DEFAULT   #
##############################

if [[ "$show_banner" != true && "$custom_desktop" != true && "$clone_git" != true && "$view_log" != true && "$install_packages" != true && "$sudo_pass" != true && "$show_version" != true ]]; then
    show_usage
    exit 1
fi

##############################
#     EXECUTION BLOCKS       #
##############################

if [[ "$show_banner" = true ]]; then
    type display_banner &>/dev/null && display_banner
    show_version=false
fi

if [[ "$clone_git" = true ]]; then
    case "${git_action:-}" in
        clone)
            git_import
        ;;
        edit)
            export editor=nano
            "$editor" "$BASE_DIR/repositories/repository_list.csv"
        ;;
        delete)
            echo -e "Deleting Git Repos...\n"
            # TODO: Add deletion logic
        ;;
        *)
            echo -e "Invalid git action: $git_action\n"
        ;;
    esac
    clone_git=false
fi

if [[ "$view_log" = true ]]; then
    less "$LOG_FILE"
    view_log=false
fi

if [[ "$install_packages" = true ]]; then
    case "${package_action:-}" in
        install)
            package_install
        ;;
        edit)
            export editor=nano
            "$editor" "$BASE_DIR/packages/package_list"
        ;;
        *)
            echo -e "Invalid package action: $package_action\n"
        ;;
    esac
    install_packages=false
fi

if [[ "$sudo_pass" = true ]]; then
    case "${sudo_action:-}" in
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
            echo -e "Invalid sudo action: $sudo_action\n"
        ;;
    esac
    sudo_pass=false
fi

if [[ "$show_version" = true ]]; then
    echo -e "v${APP_VERSION}\n"
    show_version=false
fi

if [[ "$custom_desktop" = true ]]; then
    echo -e "\e[1;31m[*] COMING SOON [*]\e[0m\n"
    custom_desktop=false
fi

# Invalidate sudo timestamp
sudo -k
