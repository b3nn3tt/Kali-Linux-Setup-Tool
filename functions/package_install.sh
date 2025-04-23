#!/usr/bin/env bash

###############################################################################
# File Name   : package_install.sh                                            #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 2.1                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Installs APT packages listed in a static file, with idempotency checks.    #
# Automatically adds i386 architecture if not present.                       #
# Logs success/failure and handles missing packages gracefully.              #
###############################################################################

package_install() {

    local PACKAGE_LIST="$BASE_DIR/packages/package_list"

    # Ensure the APT package list exists
    if [[ ! -f "$PACKAGE_LIST" ]]; then
        echo -e "\n\e[1;35m[!! MISSING PACKAGE LIST !!]\e[0m"
        echo -e "Expected a plaintext list of packages at:\n  \e[1;36m$PACKAGE_LIST\e[0m"
        exit 1
    fi

    ##############################
    # Check i386 Architecture
    ##############################

    echo -e "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking if i386 architecture is enabled..."
    sleep 1
    if dpkg --print-foreign-architectures | grep -q i386; then
        echo -e "\e[1;35m[-- SKIPPING --]\e[0m i386 support already present."
    else
        echo -e "\n\e[1;31m[!! NOT FOUND !!]\e[0m i386 architecture missing — installing now..."
        sudo dpkg --add-architecture i386
        sudo apt update
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m i386 support added."
        log_message "INFO" "ARCHITECTURE SUPPORT INSTALLED: i386"
    fi

    ##############################
    # Preview Packages to Install
    ##############################

    echo -e "\n\e[1;34mThe following APT packages will be installed:\e[0m"
    while IFS= read -r package; do
        [[ -n "$package" ]] && echo -e "  [+] $package"
    done < "$PACKAGE_LIST"

    echo -e "\nInstallation will begin in 5 seconds — \e[1;31mpress any key to cancel\e[0m."
    if read -n 1 -s -r -t 5; then
        echo -e "\n[-] Installation aborted."
        exit 1
    fi

    echo -e "\n\e[1;33;1m[>> STARTING INSTALLATION <<]\e[0m\n"

    ##############################
    # Install APT Packages
    ##############################

    while IFS= read -r required_package; do
        [[ -z "$required_package" ]] && continue

        echo -e "\n\e[1;33;1m[.. CHECKING ..]\e[0m Verifying $required_package..."
        sleep 1

        if dpkg-query -W --showformat='${Status}\n' "$required_package" 2>/dev/null | grep -q "install ok installed"; then
            echo -e "\e[1;35m[-- SKIPPING --]\e[0m $required_package is already installed."
        else
            echo -e "\e[1;31m[!! INSTALLING !!]\e[0m $required_package is not installed — proceeding..."
            sleep 1
            if sudo apt install -y "$required_package"; then
                echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m $required_package installed successfully."
                log_message "INFO" "PACKAGE INSTALLED: $required_package"
            else
                echo -e "\n\e[1;31m[!! FAILED !!]\e[0m Failed to install $required_package — skipping."
                log_message "ERROR" "INSTALL FAILED: $required_package could not be installed."
            fi
        fi
        sleep 1
    done < "$PACKAGE_LIST"

    ##############################
    # Final Completion Message
    ##############################

    echo -e "\n\e[1;32m[++ PROCESS COMPLETE ++]\e[0m All listed APT packages have been processed.\n"
    sleep 2
}
