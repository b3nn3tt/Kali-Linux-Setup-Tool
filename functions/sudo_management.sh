#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   sudo_management.sh                         #
# Description: Configures the use of sudo passwords       #
#                --------USE WITH CAUTION--------         #
#                                                         #
###########################################################

sudo_status() {
    # Check if the entry exists in the /etc/sudoers file
    if sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo -e "\n\e[1;32m[** STATUS **]\e[0m sudo password for $USER is \e[1;31mDISABLED\e[0m. You have \e[1;31mP\e[1;32mH\e[1;33mE\e[1;34mN\e[1;35mO\e[1;36mM\e[1;37mI\e[1;31mN\e[1;32mA\e[1;33mL\e[1;34m \e[1;35mC\e[1;36mO\e[1;37mS\e[1;31mM\e[1;32mI\e[1;33mC\e[1;34m \e[1;35mP\e[1;36mO\e[1;37mW\e[1;31mE\e[1;32mR\e[0m!"
    else
        echo -e "\n\e[1;32m[** STATUS **]\e[0m sudo password for $USER is \e[1;32mENABLED\e[0m."
    fi
}

enable_sudo_pass(){
    
    echo -e "\n\e[1;32mThis will reactivate sudo password requirements\e[0m"
    sleep 1
    echo -e "\n\n\e[1;31msudo password will be reactivated in 5 seconds - press any key to abort:\e[0m"
    
    # Wait for 5 seconds for a keypress; if a key is pressed, the script will exit the function
    if read -n 1 -s -r -t 5; then
        echo -e "\n[-] Operation aborted"
        return
    fi
    
    # Check if the entry exists in the /etc/sudoers file
    if sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        # If the entry exist, remove it
        echo -e "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Modifying sudo configuration now..."
        sleep 1
        sudo sed -i "/^$USER ALL=(ALL) NOPASSWD:ALL$/d" /etc/sudoers
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration complete - you once again require a sudo password. Order has been restored"
        log_message "INFO" "CONFIGURATION: sudo password RE-ENABLED."
    else
        echo -e "\n\e[1;35m[-- SKIPPING --]\e[0m sudo password is already enabled for $USER"
    fi
}

disable_sudo_pass(){
    
    # Warning - makes clear that this is a purely convenience-driven option - not fit for a production system
    echo -e "\n\e[1;31m[!! WARNING !!]\e[0m Proceeding will enable sudo access without requiring a password \e[1;31m[!! WARNING !!]\e[0m"
    sleep 2
    echo -e "\n\e[1;35mUse this option judiciously - it is intended solely for convenience in a testing environment - NEVER USE THIS IN PRODUCTION.\e[0m"
    sleep 1
    echo -e "\n\n\e[1;31msudo password will be disabled in 5 seconds - press any key to abort:\e[0m"

    # Wait for 5 seconds for a keypress; if a key is pressed, the script will exit the function
    if read -n 1 -s -r -t 5; then
        echo -e "\n[-] Operation aborted"
        return
    fi

    # Check if the entry exists in the /etc/sudoers file
    if ! sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        # If the entry doesn't exist, append it
        echo -e "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Modifying sudo configuration now..."
        sleep 1
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration complete - you now have \e[1;31mP\e[1;32mH\e[1;33mE\e[1;34mN\e[1;35mO\e[1;36mM\e[1;37mI\e[1;31mN\e[1;32mA\e[1;33mL\e[1;34m \e[1;35mC\e[1;36mO\e[1;37mS\e[1;31mM\e[1;32mI\e[1;33mC\e[1;34m \e[1;35mP\e[1;36mO\e[1;37mW\e[1;31mE\e[1;32mR\e[0m! Remember, with great power comes great responsibility..."
        log_message "WARNING" "CONFIGURATION: sudo password DISABLED."
    else
        echo -e "\n\e[1;35m[-- SKIPPING --]\e[0m sudo password is already disabled for $USER"
    fi
}