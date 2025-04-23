#!/usr/bin/env bash

###############################################################################
# File Name   : sudo_management.sh                                            #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.1                                                           #
# GitHub      : https://github.com/InfoSec-Research/                          #
#                                                                             #
# Description :                                                               #
# Configures sudo password requirements. Intended only for testing or lab    #
# use — not production environments.                                          #
###############################################################################

sudo_status() {
    if sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo -e "\n\e[1;32m[** STATUS **]\e[0m sudo password for $USER is \e[1;31mDISABLED\e[0m."
        echo -e "You currently possess \e[1;31mP\e[1;32mH\e[1;33mE\e[1;34mN\e[1;35mO\e[1;36mM\e[1;37mI\e[1;31mN\e[1;32mA\e[1;33mL\e[1;34m \e[1;35mC\e[1;36mO\e[1;37mS\e[1;31mM\e[1;32mI\e[1;33mC\e[1;34m \e[1;35mP\e[1;36mO\e[1;37mW\e[1;31mE\e[1;32mR\e[0m!"
        log_message "INFO" "STATUS: sudo password is DISABLED for $USER"
    else
        echo -e "\n\e[1;32m[** STATUS **]\e[0m sudo password for $USER is \e[1;32mENABLED\e[0m."
        log_message "INFO" "STATUS: sudo password is ENABLED for $USER"
    fi
}

enable_sudo_pass() {
    echo -e "\n\e[1;32mThis will re-enable sudo password prompts.\e[0m"
    sleep 1
    echo -e "\n\e[1;31mOperation will continue in 5 seconds — press any key to abort.\e[0m"

    if read -n 1 -s -r -t 5; then
        echo -e "\n[-] Operation aborted."
        return
    fi

    if sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo -e "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Modifying sudo configuration..."
        sleep 1
        sudo sed -i "/^$USER ALL=(ALL) NOPASSWD:ALL$/d" /etc/sudoers
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m sudo password requirement re-enabled for $USER."
        log_message "INFO" "CONFIGURATION: sudo password RE-ENABLED for $USER"
    else
        echo -e "\n\e[1;35m[-- SKIPPING --]\e[0m Password requirement already enabled for $USER."
        log_message "INFO" "SKIP: sudo password already enabled for $USER"
    fi
}

disable_sudo_pass() {
    echo -e "\n\e[1;31m[!! WARNING !!]\e[0m This will disable sudo password prompts."
    echo -e "\e[1;35mUse only in trusted, local, or lab environments.\e[0m"
    sleep 2
    echo -e "\n\e[1;31mOperation will continue in 5 seconds — press any key to abort.\e[0m"

    if read -n 1 -s -r -t 5; then
        echo -e "\n[-] Operation aborted."
        return
    fi

    if ! sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        echo -e "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Modifying sudo configuration..."
        sleep 1
        echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers > /dev/null
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m You now have \e[1;31mP\e[1;32mH\e[1;33mE\e[1;34mN\e[1;35mO\e[1;36mM\e[1;37mI\e[1;31mN\e[1;32mA\e[1;33mL\e[1;34m \e[1;35mC\e[1;36mO\e[1;37mS\e[1;31mM\e[1;32mI\e[1;33mC\e[1;34m \e[1;35mP\e[1;36mO\e[1;37mW\e[1;31mE\e[1;32mR\e[0m!"
        echo -e "Remember: with great power comes great responsibility.\n"
        log_message "WARNING" "CONFIGURATION: sudo password DISABLED for $USER"
    else
        echo -e "\n\e[1;35m[-- SKIPPING --]\e[0m sudo password already disabled for $USER."
        log_message "INFO" "SKIP: sudo password already disabled for $USER"
    fi
}
