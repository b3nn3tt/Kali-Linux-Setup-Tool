#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   package_install.sh                         #
# Description: Installs packages via apt from a static,   #
#              prepopulated list                          #
#                                                         #
###########################################################

package_install() {
    # Static list of packages to install
    PACKAGE_LIST="$BASE_DIR/packages/package_list"
    
    if [ ! -f "$PACKAGE_LIST" ]; then
        echo -e "\n\e[1;35m[** MISSING PACKAGE LIST **]\e[0m A required file listing packages to be installed was not found. Please ensure a plaintext file with package names, each on a separate line, exists at: $PACKAGE_LIST"
        exit 1
    fi
    
    # Add i386 Architecture
    echo -e "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking if the i386 architecture is already installed..."
    sleep 2
    if dpkg --print-foreign-architectures | grep -q i386; then
        echo -e "\e[1;35m[-- SKIPPING --]\e[0m i386 architecture support is already installed."
        sleep 2
    else
        echo -e "\n\e[1;31m[!! ARCHITECTURE NOT FOUND !!]\e[0m i386 architecture support not detected - initiating installation..."
        sleep 2
        sudo dpkg --add-architecture i386
        sudo apt update
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m i386 Architecture support installed successfully."
        log_message "INFO" "ARCHITECTURE SUPPORT INSTALLED: i386 installed successfully."
        sleep 2
    fi
    
    # Lists the contents of the packages_list file, displaying what will be installed via apt
    echo -e "\nThe following packages will be installed:\n"
    while IFS= read -r package; do
        echo -e "[+] $package"
    done < "$PACKAGE_LIST"
    echo -e "\nInstallation will commence in 5 seconds - \e[1;31mpress any key to abort:\e[0m"
    if read -n 1 -s -r -t 5 -p ""; then
        echo -e "[-] Installation aborted"
        exit 1
    fi
    echo -e "Starting installation...\n"
    
    # Package installation logic
    while IFS= read -r required_package; do
        echo -e "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking if $required_package is already installed..."
        sleep 1
        if dpkg-query -W --showformat='${Status}\n' "$required_package" 2>/dev/null | grep -q "install ok installed"; then
            echo -e "\e[1;35m[-- SKIPPING --]\e[0m $required_package is already installed."
            sleep 1
        else
            echo -e "\n\e[1;31m[!! PACKAGE NOT FOUND !!]\e[0m $required_package is absent - proceeding with installation...\n"
            sleep 1
            sudo apt install -y "$required_package"
            echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m $required_package installed successfully."
            log_message "INFO" "PACKAGE INSTALLED: $required_package installed successfully."
            sleep 1
        fi
    done < "$PACKAGE_LIST"
    
    # Configures Veil Evasion post install
    if dpkg-query -W --showformat='${Status}\n' "veil" 2>/dev/null | grep -q "install ok installed"; then
        echo -e "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking the installation status of Veil..."
        sleep 1
        
        # Check if configuration has already been done by examining the log file - skips if already configured
        if grep -q "CONFIGURATION: Veil" "$LOG_FILE"; then
            echo -e "\n\e[1;35m[-- SKIPPING --]\e[0m Veil has already been configured."
        else
            echo -e "\n\e[1;33;1m[== CONFIGURING ==]\e[0m Veil is installed but requires configuration - starting the setup process now..."
            sleep 2
            sudo /usr/share/veil/config/setup.sh --force --silent
            sleep 2
            echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration of Veil complete."
            log_message "INFO" "CONFIGURATION: Veil Evasion configuration complete."
        fi
    fi
    
    # PIP Section - Checks first to see if the package has already been installed. If not, then installation is performed. If so, then installation is skipped...
    
    # Static list of PIP packages to install
    PIP_PACKAGE_LIST="$BASE_DIR/packages/pip_package_list"
    
    # Checks for the presence of the static PIP package list
    if [ ! -f "$PIP_PACKAGE_LIST" ]; then
        echo -e "\n\e[1;35m[!! MISSING PACKAGE LIST !!]\e[0m A required file listing PIP packages to be installed was not found. Please ensure a plaintext file with package names, each on a separate line, exists at: $PIP_PACKAGE_LIST"
        exit 1
    fi
    
    # Static list of PIP packages to install
    echo -e "\n\nNext, the following PIP packages will be installed:\n"
    while IFS= read -r package; do
        echo -e "[+] $package"
    done < "$PIP_PACKAGE_LIST"
    echo -e "\nInstallation will commence in 5 seconds - \e[1;31mpress any key to abort:\e[0m"
    if read -n 1 -s -r -t 5 -p ""; then
        echo -e "[-] Installation aborted"
        exit 1
    fi
    echo -e "Starting installation...\n"
    
    # PIP package installation logic
    while IFS= read -r required_pippackage; do
        echo -e "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking if $required_pippackage is already installed..."
        sleep 1
        if pip3 list 2>/dev/null | grep -i "^$required_pippackage\s"; then
            echo -e "\e[1;35m[-- SKIPPING --]\e[0m $required_pippackage is already installed."
            sleep 1
        else
            echo -e "\n\e[1;31m[!! PACKAGE NOT FOUND !!]\e[0m $required_pippackage is absent - proceeding with installation...\n"
            sleep 1
            pip3 install "$required_pippackage"
            echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m $required_pippackage installed successfully."
            log_message "INFO" "PIP3 PACKAGE INSTALLED: $required_pippackage installed successfully."
            sleep 1
        fi
        
    done < "$PIP_PACKAGE_LIST"
    
    sleep 2
    echo -e "\n\e[1;32m[++ PROCESS COMPLETE ++]\e[0m All tools have been successfully installed and configured."
    sleep 2
}