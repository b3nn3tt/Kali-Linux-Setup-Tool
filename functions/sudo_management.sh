#!/usr/bin/env bash

###############################################################################
# File Name   : sudo_management.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.1
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Configures sudo password requirements using /etc/sudoers.d/ drop-in files
# instead of editing /etc/sudoers directly.
#
# NOTE: Intended only for testing or lab environments.
###############################################################################

readonly SUDOERS_DROPIN="/etc/sudoers.d/99-kali-setup-nopasswd"


sudo_status() {

    if [[ -f "$SUDOERS_DROPIN" ]] && sudo grep -q "NOPASSWD" "$SUDOERS_DROPIN" 2>/dev/null; then

        msg_info "Sudo password for ${CLR_BOLD}${USER}${CLR_RESET} is ${CLR_RED}DISABLED${CLR_RESET}."
        printf "  You currently possess %bP%bH%bE%bN%bO%bM%bI%bN%bA%bL %bC%bO%bS%bM%bI%bC %bP%bO%bW%bE%bR%b!\n" \
            "${CLR_RED}" "${CLR_GREEN}" "${CLR_YELLOW}" "${CLR_BLUE}" "${CLR_MAGENTA}" "${CLR_CYAN}" "${CLR_WHITE}" \
            "${CLR_RED}" "${CLR_GREEN}" "${CLR_YELLOW}" \
            "${CLR_MAGENTA}" "${CLR_CYAN}" "${CLR_WHITE}" "${CLR_RED}" "${CLR_GREEN}" "${CLR_YELLOW}" \
            "${CLR_MAGENTA}" "${CLR_CYAN}" "${CLR_WHITE}" "${CLR_RED}" "${CLR_GREEN}" "${CLR_RESET}"

        log_message "INFO" "STATUS: sudo password is DISABLED for ${USER}"

    else

        msg_info "Sudo password for ${CLR_BOLD}${USER}${CLR_RESET} is ${CLR_GREEN}ENABLED${CLR_RESET}."
        log_message "INFO" "STATUS: sudo password is ENABLED for ${USER}"

    fi
}


enable_sudo_pass() {

    msg_info "This will re-enable sudo password prompts."

    confirm_countdown 5 "Password re-enablement will proceed" || return 0

    if [[ -f "$SUDOERS_DROPIN" ]]; then

        msg_action "Removing passwordless sudo configuration..."

        run_cmd sudo rm -f "$SUDOERS_DROPIN"

        msg_ok "Sudo password requirement re-enabled for ${CLR_BOLD}${USER}${CLR_RESET}."
        log_message "INFO" "CONFIGURATION: sudo password RE-ENABLED for ${USER}"

    else

        msg_skip "Password requirement is already enabled for ${USER}."
        log_message "INFO" "SKIP: sudo password already enabled for ${USER}"

    fi
}


disable_sudo_pass() {

    msg_warn "This will ${CLR_RED}disable${CLR_RESET} sudo password prompts for ${CLR_BOLD}${USER}${CLR_RESET}."
    msg_warn "Use only in trusted, local, or lab environments."

    confirm_countdown 5 "Password disablement will proceed" || return 0

    if [[ ! -f "$SUDOERS_DROPIN" ]]; then

        msg_action "Writing passwordless sudo configuration..."

        local tmp_file
        tmp_file="$(mktemp)"

        printf "%s ALL=(ALL) NOPASSWD:ALL\n" "$USER" > "$tmp_file"

        if run_cmd sudo visudo -cf "$tmp_file"; then

            run_cmd sudo cp "$tmp_file" "$SUDOERS_DROPIN"
            run_cmd sudo chmod 0440 "$SUDOERS_DROPIN"

            rm -f "$tmp_file"

            printf "  You now have %bP%bH%bE%bN%bO%bM%bI%bN%bA%bL %bC%bO%bS%bM%bI%bC %bP%bO%bW%bE%bR%b!\n" \
                "${CLR_RED}" "${CLR_GREEN}" "${CLR_YELLOW}" "${CLR_BLUE}" "${CLR_MAGENTA}" "${CLR_CYAN}" "${CLR_WHITE}" \
                "${CLR_RED}" "${CLR_GREEN}" "${CLR_YELLOW}" \
                "${CLR_MAGENTA}" "${CLR_CYAN}" "${CLR_WHITE}" "${CLR_RED}" "${CLR_GREEN}" "${CLR_YELLOW}" \
                "${CLR_MAGENTA}" "${CLR_CYAN}" "${CLR_WHITE}" "${CLR_RED}" "${CLR_GREEN}" "${CLR_RESET}"

            printf "  Remember: with great power comes great responsibility.\n"

            log_message "WARNING" "CONFIGURATION: sudo password DISABLED for ${USER}"

        else

            rm -f "$tmp_file"

            msg_error "Sudoers syntax validation failed — no changes made."
            log_message "ERROR" "Sudoers validation failed when disabling password for ${USER}"

            return 1

        fi

    else

        msg_skip "Sudo password is already disabled for ${USER}."
        log_message "INFO" "SKIP: sudo password already disabled for ${USER}"

    fi
}