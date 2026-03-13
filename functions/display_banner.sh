#!/usr/bin/env bash

###############################################################################
# File Name   : display_banner.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.1
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Displays the Kali Linux Setup Tool banner with version and tagline.
# Uses centralised colour constants and reads APP_VERSION dynamically.
###############################################################################

display_banner() {

    # Respect quiet mode
    [[ "${QUIET:-false}" == true ]] && return 0

    printf "\n"

    printf "%b\n" "${CLR_BLUE}               __ __      ___    __    _${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}              / //_/___ _/ (_)  / /   (_)___  __  ___  __${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}             / ,< / __ \`/ / /  / /   / / __ \\/ / / / |/_/${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}            / /| / /_/ / / /  / /___/ / / / / /_/ />  <${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}           /_/ |_\\__,_/_/_/  /_____/_/_/ /_/\\__,_/_/|_|${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}          _____      __                 ______            __${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}         / ___/___  / /___  ______     /_  __/___  ____  / /${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}         \\__ \\/ _ \\/ __/ / / / __ \\     / / / __ \\/ __ \\/ /${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}        ___/ /  __/ /_/ /_/ / /_/ /    / / / /_/ / /_/ / /${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}       /____/\\___/\\__/\\__,_/ .___/    /_/  \\____/\\____/_/${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}                          /_/${CLR_RESET}"

    printf "\n"
    printf "%b\n" "     ${CLR_YELLOW}A tool to prepare Kali Linux for penetration testing.${CLR_RESET}"
    printf "\n"

    # Dynamic version box — width adapts to version string length
    local ver_text="Version ${APP_VERSION}"
    local ver_len=${#ver_text}
    local box_width=$(( ver_len + 6 ))
    local border

    border=$(printf '─%.0s' $(seq 1 "$box_width"))

    printf "%b\n" "                       ${CLR_YELLOW}┌${border}┐${CLR_RESET}"
    printf "%b\n" "                       ${CLR_YELLOW}│   ${ver_text}   │${CLR_RESET}"
    printf "%b\n" "                       ${CLR_YELLOW}└${border}┘${CLR_RESET}"

    printf "\n"
}