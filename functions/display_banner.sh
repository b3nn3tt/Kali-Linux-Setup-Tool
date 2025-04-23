#!/usr/bin/env bash

###############################################################################
# File Name   : display_banner.sh                                             #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 1.2                                                           #
# GitHub      : https://github.com/b3nn3tt                                    #
#                                                                             #
# Description :                                                               #
# Displays the Kali Linux Setup Tool banner with version and tagline.        #
###############################################################################

display_banner() {
    echo
    echo -e "\e[1;34m               __ __      ___    __    _\e[0m"
    echo -e "\e[1;34m              / //_/___ _/ (_)  / /   (_)___  __  ___  __\e[0m"
    echo -e "\e[1;34m             / ,< / __ \`/ / /  / /   / / __ \/ / / / |/_/\e[0m"
    echo -e "\e[1;34m            / /| / /_/ / / /  / /___/ / / / / /_/ />  <\e[0m"
    echo -e "\e[1;34m           /_/ |_\__,_/_/_/  /_____/_/_/ /_/\__,_/_/|_|\e[0m"
    echo -e "\e[1;34m          _____      __                 ______            __\e[0m"
    echo -e "\e[1;34m         / ___/___  / /___  ______     /_  __/___  ____  / /\e[0m"
    echo -e "\e[1;34m         \__ \/ _ \/ __/ / / / __ \     / / / __ \/ __ \/ /\e[0m"
    echo -e "\e[1;34m        ___/ /  __/ /_/ /_/ / /_/ /    / / / /_/ / /_/ / /\e[0m"
    echo -e "\e[1;34m       /____/\___/\__/\__,_/ .___/    /_/  \____/\____/_/\e[0m"
    echo -e "\e[1;34m                          /_/\e[0m"
    echo

    # Tagline
    echo -e "     \e[1;33mA tool to prepare Kali Linux for penetration testing.\e[0m"
    echo

    # Version box
    echo -e "\e[1;33m                       -------------------\e[0m"
    echo -e "\e[1;33m                       |    Version 3.0   |\e[0m"
    echo -e "\e[1;33m                       -------------------\e[0m"
    echo

    # Optional timestamp (commented by default)
    # echo -e "               \e[2mSession started at $(date +"%Y-%m-%d %H:%M:%S")\e[0m"
}
