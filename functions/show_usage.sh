#!/usr/bin/env bash

###############################################################################
# File Name   : show_usage.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.1
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Displays general usage and module-specific help for the setup tool.
###############################################################################

show_usage() {

    local cmd
    cmd="$(basename "$0")"

    printf "\n"
    printf "%b\n" "${CLR_YELLOW}Usage:${CLR_RESET} ${cmd} [OPTIONS] [--dry-run] [--verbose] [--quiet]"
    printf "\n"

    printf "%b\n" "${CLR_BOLD}Module options:${CLR_RESET}"
    printf "  -a, --all              Run all modules (excludes log viewer)\n"
    printf "  -b, --banner           Display ASCII tool banner\n"
    printf "  -d, --desktop          Configure custom desktop experience\n"
    printf "  -g, --git <action>     Manage Git repositories (clone|edit|delete)\n"
    printf "  -h, --help             Display this help message\n"
    printf "  -l, --log              View the session log file\n"
    printf "  -p, --packages <act>   Manage APT packages (install|edit)\n"
    printf "  -r, --rcsetup <act>   Manage zsh shell customisation (install|edit|remove)\n"
    printf "  -s, --sudo <action>    Configure sudo behaviour (status|activate|disable)\n"
    printf "  -u, --update           Force a full system update\n"
    printf "  -v, --version          Display tool version\n"

    printf "\n"

    printf "%b\n" "${CLR_BOLD}Global modifiers:${CLR_RESET}"
    printf "  --dry-run              Show what would happen without making changes\n"
    printf "  --verbose              Enable debug-level output\n"
    printf "  -q, --quiet            Suppress informational output (errors still shown)\n"
    printf "  --paths                Show resolved directory paths and exit\n"

    printf "\n"

    printf "%b\n" "${CLR_BOLD}Examples:${CLR_RESET}"
    printf "\n"

    printf "  Install packages from the package list:\n"
    printf "    %b%s -p install%b\n" "${CLR_CYAN}" "$cmd" "${CLR_RESET}"
    printf "\n"

    printf "  Clone all Git repos (dry run):\n"
    printf "    %b%s -g clone --dry-run%b\n" "${CLR_CYAN}" "$cmd" "${CLR_RESET}"
    printf "\n"

    printf "  Run Git cloning and package installation together:\n"
    printf "    %b%s -g clone -p install%b\n" "${CLR_CYAN}" "$cmd" "${CLR_RESET}"
    printf "\n"

    printf "  Check sudo status with verbose output:\n"
    printf "    %b%s -s status --verbose%b\n" "${CLR_CYAN}" "$cmd" "${CLR_RESET}"
    printf "\n"
}


show_git_usage() {

    printf "\n"
    msg_warn "Git module requires an action argument."
    printf "\n"

    printf "  -g clone  | --git clone     Clone/update repositories from the list\n"
    printf "  -g edit   | --git edit      Edit the repository list (CSV)\n"
    printf "  -g delete | --git delete    Remove managed repository directories\n"
    printf "\n"
}


show_package_usage() {

    printf "\n"
    msg_warn "Package module requires an action argument."
    printf "\n"

    printf "  -p install | --packages install    Install APT packages from the list\n"
    printf "  -p edit    | --packages edit       Edit the APT package list\n"
    printf "\n"
}


show_sudo_usage() {

    printf "\n"
    msg_warn "Sudo module requires an action argument."
    printf "\n"

    printf "  -s status   | --sudo status       Show current sudo configuration\n"
    printf "  -s activate | --sudo activate     Re-enable sudo password prompts\n"
    printf "  -s disable  | --sudo disable      Disable sudo password (lab use only)\n"
    printf "\n"
}


show_shell_usage() {

    printf "\n"
    msg_warn "Shell customisation module requires an action argument."
    printf "\n"

    printf "  -r install      | --rcsetup install       Deploy snippets (asks: user or both)\n"
    printf "  -r install-user | --rcsetup install-user   Deploy snippets for current user only\n"
    printf "  -r install-all  | --rcsetup install-all    Deploy snippets for current user + root\n"
    printf "  -r edit         | --rcsetup edit            Edit deployed snippet files\n"
    printf "  -r remove       | --rcsetup remove          Remove snippets and sourcing block\n"
    printf "\n"
}