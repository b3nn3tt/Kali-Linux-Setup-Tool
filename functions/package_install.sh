#!/usr/bin/env bash

###############################################################################
# File Name   : package_install.sh                                            
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              
# Version     : 4.0                                                           
# GitHub      : https://github.com/InfoSec-Research/                          
#                                                                             
# Description :                                                               
# Installs APT packages listed in a static file, with idempotency checks.    
# Automatically adds i386 architecture if not present.                       
###############################################################################

package_install() {
    local package_list="${PACKAGE_LIST}"

    # ─── Validate package list exists ─────────────────────────────────────
    if [[ ! -f "$package_list" ]]; then
        msg_error "Package list not found at: ${package_list}"
        msg_info  "Create a plaintext file with one package name per line."
        return 1
    fi

    # ─── Check i386 architecture ──────────────────────────────────────────
    msg_action "Checking i386 architecture support..."

    if dpkg --print-foreign-architectures 2>/dev/null | grep -q i386; then
        msg_skip "i386 support already enabled."
    else
        msg_action "Adding i386 architecture..."
        run_cmd sudo dpkg --add-architecture i386
        run_cmd sudo apt update
        msg_ok "i386 support added."
        log_message "INFO" "ARCHITECTURE: i386 support installed."
    fi

    # ─── Preview packages ─────────────────────────────────────────────────
    echo ""
    msg_info "The following APT packages will be installed:"
    echo ""
    while IFS= read -r package || [[ -n "$package" ]]; do
        [[ -z "$package" || "$package" =~ ^[[:space:]]*# ]] && continue
        echo "    ${package}"
    done < "$package_list"
    echo ""

    confirm_countdown 5 "Package installation will begin" || return 0

    # ─── Install packages ─────────────────────────────────────────────────
    msg_action "Starting package installation..."
    echo ""

    local installed=0
    local skipped=0
    local failed=0

    while IFS= read -r required_package || [[ -n "$required_package" ]]; do
        # Skip blank lines and comments
        [[ -z "$required_package" || "$required_package" =~ ^[[:space:]]*# ]] && continue

        # Trim whitespace
        required_package="$(echo "$required_package" | xargs)"

        msg_action "Checking ${CLR_BOLD}${required_package}${CLR_RESET}..."

        if dpkg-query -W --showformat='${Status}\n' "$required_package" 2>/dev/null | grep -q "install ok installed"; then
            msg_skip "${required_package} is already installed."
            (( skipped++ ))
        else
            if run_cmd sudo apt install -y "$required_package"; then
                msg_ok "${required_package} installed successfully."
                log_message "INFO" "PACKAGE INSTALLED: ${required_package}"
                (( installed++ ))
            else
                msg_error "Failed to install ${required_package} — skipping."
                log_message "ERROR" "INSTALL FAILED: ${required_package}"
                (( failed++ ))
            fi
        fi
    done < "$package_list"

    # ─── Summary ──────────────────────────────────────────────────────────
    echo ""
    msg_ok "Package operations complete."
    msg_info "  Installed: ${installed}  |  Skipped: ${skipped}  |  Failed: ${failed}"
    echo ""
}
