#!/usr/bin/env bash

###############################################################################
# File Name   : 00_core_colours.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.2
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Centralised colour definitions and output helper functions. All modules
# should use these functions rather than embedding raw ANSI escape codes.
#
# Naming convention: Files prefixed with 00_ are loaded first to ensure
# their definitions are available to all subsequent function files.
###############################################################################


# ─────────────────────────────────────────────────────────────────────────────
# Detect colour support
# ─────────────────────────────────────────────────────────────────────────────
# If stdout is not a terminal (e.g. piped to a file) colours are disabled.

if [[ -t 1 ]] && command -v tput &>/dev/null && [[ $(tput colors 2>/dev/null || echo 0) -ge 8 ]]; then

    readonly CLR_RESET='\e[0m'
    readonly CLR_BOLD='\e[1m'
    readonly CLR_DIM='\e[2m'

    # Standard colours
    readonly CLR_RED='\e[1;31m'
    readonly CLR_GREEN='\e[1;32m'
    readonly CLR_YELLOW='\e[1;33m'
    readonly CLR_BLUE='\e[1;34m'
    readonly CLR_MAGENTA='\e[1;35m'
    readonly CLR_CYAN='\e[1;36m'
    readonly CLR_WHITE='\e[1;37m'

    # Muted / secondary colours
    readonly CLR_DIM_RED='\e[91m'
    readonly CLR_DIM_GREY='\e[90m'

else

    # Colour disabled
    readonly CLR_RESET=''
    readonly CLR_BOLD=''
    readonly CLR_DIM=''
    readonly CLR_RED=''
    readonly CLR_GREEN=''
    readonly CLR_YELLOW=''
    readonly CLR_BLUE=''
    readonly CLR_MAGENTA=''
    readonly CLR_CYAN=''
    readonly CLR_WHITE=''
    readonly CLR_DIM_RED=''
    readonly CLR_DIM_GREY=''

fi


# ─────────────────────────────────────────────────────────────────────────────
# Output helper functions
# ─────────────────────────────────────────────────────────────────────────────
# These provide consistent prefixed output across modules.
# Behaviour respects global flags: VERBOSE and QUIET.
#
# Usage examples:
#   msg_info    "Checking package list..."
#   msg_ok      "Package installed successfully"
#   msg_warn    "Disk space is low"
#   msg_error   "File not found"
#   msg_fatal   "Cannot continue without root"
#   msg_skip    "Already installed"
#   msg_action  "Installing dependencies..."
#   msg_debug   "Variable x = $x"


msg_info() {
    [[ "${QUIET:-false}" == true ]] && return 0
    printf "%b\n" "${CLR_BLUE}[*]${CLR_RESET} $1"
}

msg_ok() {
    [[ "${QUIET:-false}" == true ]] && return 0
    printf "%b\n" "${CLR_GREEN}[+]${CLR_RESET} $1"
}

msg_warn() {
    # Warnings always print
    printf "%b\n" "${CLR_YELLOW}[!]${CLR_RESET} $1"
}

msg_error() {
    # Errors always print
    printf "%b\n" "${CLR_RED}[!!]${CLR_RESET} $1" >&2
}

msg_fatal() {
    printf "%b\n" "${CLR_RED}[!! FATAL !!]${CLR_RESET} $1" >&2

    # Log fatal event if logging system is available
    if type log_message &>/dev/null; then
        log_message "FATAL" "$1"
    fi

    return 1
}

msg_skip() {
    [[ "${QUIET:-false}" == true ]] && return 0
    printf "%b\n" "${CLR_MAGENTA}[--]${CLR_RESET} $1"
}

msg_action() {
    [[ "${QUIET:-false}" == true ]] && return 0
    printf "%b\n" "${CLR_YELLOW}[..]${CLR_RESET} $1"
}

msg_debug() {
    [[ "${VERBOSE:-false}" != true ]] && return 0
    printf "%b\n" "${CLR_DIM_GREY}[DBG] $1${CLR_RESET}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Confirmation prompt
# ─────────────────────────────────────────────────────────────────────────────
# Timed confirmation prompt.
#
# Returns:
#   0 → continue
#   1 → aborted
#
# In DRY_RUN mode this always aborts but prints what would happen.


confirm_countdown() {

    local seconds="${1:-5}"
    local action_label="${2:-Operation will begin}"

    if [[ "${DRY_RUN:-false}" == true ]]; then
        msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would proceed with: ${action_label}"
        return 1
    fi

    echo ""
    printf "%b\n" "${action_label} in ${CLR_RED}${seconds}${CLR_RESET} seconds — press any key to abort."

    if read -r -s -n 1 -t "$seconds"; then
        echo ""
        msg_warn "Operation aborted by user."
        return 1
    fi

    echo ""
    return 0
}


# ─────────────────────────────────────────────────────────────────────────────
# Section header helper
# ─────────────────────────────────────────────────────────────────────────────
# Prints a visually distinct header for major operations.
#
# Example:
#   print_section "Git Repository Management"


print_section() {

    [[ "${QUIET:-false}" == true ]] && return 0

    local title="$1"
    local width=60
    local pad=$(( (width - ${#title} - 2) / 2 ))
    local line

    line=$(printf '─%.0s' $(seq 1 "$width"))

    echo ""
    printf "%b\n" "${CLR_BLUE}${line}${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}$(printf '%*s' "$pad" '')${CLR_BOLD} ${title} ${CLR_RESET}"
    printf "%b\n" "${CLR_BLUE}${line}${CLR_RESET}"
    echo ""
}