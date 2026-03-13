#!/usr/bin/env bash

###############################################################################
# File Name   : perform_system_update.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.1
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Performs a full system-wide package update using APT and records the
# timestamp via the state-file mechanism.
###############################################################################

perform_system_update() {

    print_section "System Update"

    msg_action "A full system update will now commence."
    printf "\n"

    if [[ "${DRY_RUN:-false}" == true ]]; then
        msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would run: sudo apt update && sudo apt upgrade -y"
        record_update_timestamp
        return 0
    fi

    read -r -n 1 -s -p "  Press any key to continue, or Ctrl+C to abort..."
    printf "\n"

    # Run update and upgrade separately so failures are detected properly
    if run_cmd sudo apt update; then

        if run_cmd sudo apt upgrade -y; then

            record_update_timestamp
            log_message "NOTICE" "Full system update completed via APT."
            msg_ok "Full system update complete."

        else
            msg_error "APT upgrade failed."
            log_message "ERROR" "APT upgrade failed during system update."
            return 1
        fi

    else
        msg_error "APT update failed."
        log_message "ERROR" "APT update failed during system update."
        return 1
    fi

    printf "\n"
}