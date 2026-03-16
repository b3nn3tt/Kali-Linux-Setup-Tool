#!/usr/bin/env bash

###############################################################################
# File Name   : 02_core_logging.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.3
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Centralised logging with severity levels, automatic rotation, and update
# tracking. Hardened against set -u (nounset) crashes.
###############################################################################


# ─────────────────────────────────────────────────────────────────────────────
# Log severity levels
# ─────────────────────────────────────────────────────────────────────────────

declare -A LOG_LEVELS=(
    [DEBUG]=0
    [INFO]=1
    [NOTICE]=2
    [WARNING]=3
    [ERROR]=4
    [FATAL]=5
)

readonly MIN_LOG_LEVEL="${LOG_LEVEL:-INFO}"


# ─────────────────────────────────────────────────────────────────────────────
# Logging configuration
# ─────────────────────────────────────────────────────────────────────────────

readonly UPDATE_STAMP_FILE="${STATE_DIR}/last_system_update"
readonly LOG_MAX_SIZE_KB=512


# ─────────────────────────────────────────────────────────────────────────────
# Initialise logging
# ─────────────────────────────────────────────────────────────────────────────

init_logging() {

    mkdir -p "$LOG_DIR" "$STATE_DIR"

    if [[ -f "$LOG_FILE" ]]; then

        local size_kb
        size_kb=$(du -k "$LOG_FILE" | awk '{print $1}')

        if (( size_kb > LOG_MAX_SIZE_KB )); then

            local rotated
            rotated="${LOG_FILE}.$(date +%Y%m%d%H%M%S).bak"

            mv "$LOG_FILE" "$rotated"

            msg_debug "Log rotated to ${rotated}"
        fi
    fi


    if [[ ! -f "$LOG_FILE" ]]; then

        cat <<EOF > "$LOG_FILE"
*****************************************************************
*  ${APP_NAME} — Session Log
*  Created: $(date +"%Y-%m-%d %H:%M:%S")
*****************************************************************

EOF

        msg_debug "Log file created at ${LOG_FILE}"
    fi

    msg_debug "Logging initialised (min level: ${MIN_LOG_LEVEL})."
}


# ─────────────────────────────────────────────────────────────────────────────
# Core logging function
# ─────────────────────────────────────────────────────────────────────────────

log_message() {

    local severity="${1:-INFO}"
    local message="${2:-}"

    local sev_num
    local min_num

    # Temporarily disable nounset to safely check associative keys
    set +u

    sev_num="${LOG_LEVELS[$severity]}"
    min_num="${LOG_LEVELS[$MIN_LOG_LEVEL]}"

    set -u

    # Fallback defaults if unset
    sev_num="${sev_num:-1}"
    min_num="${min_num:-1}"

    if (( sev_num < min_num )); then
        return 0
    fi

    local timestamp
    timestamp="$(date +"%Y-%m-%d %H:%M:%S")"

    local hostname
    hostname="$(hostname)"

    printf "%s %s %s[%s]: %s: %s\n" \
        "$timestamp" "$hostname" "$APP_NAME" "$$" "$severity" "$message" \
        >> "$LOG_FILE"
}


# ─────────────────────────────────────────────────────────────────────────────
# Update tracking
# ─────────────────────────────────────────────────────────────────────────────

record_update_timestamp() {

    date +%s > "$UPDATE_STAMP_FILE"

    log_message "NOTICE" "System update timestamp recorded."

    msg_debug "Update timestamp written to ${UPDATE_STAMP_FILE}"
}


get_last_update_timestamp() {

    if [[ -f "$UPDATE_STAMP_FILE" ]]; then
        cat "$UPDATE_STAMP_FILE"
    else
        echo "0"
    fi
}


# Returns:
#   0 → no previous update has ever been recorded (first run)
#   1 → an update has been recorded previously

is_first_run() {
    [[ ! -f "$UPDATE_STAMP_FILE" ]]
}


# Returns:
#   0 → update required
#   1 → update not required

is_update_due() {

    local max_age_seconds="${1:-604800}"

    local last_update
    last_update="$(get_last_update_timestamp)"

    local now
    now="$(date +%s)"

    local age=$(( now - last_update ))

    if (( last_update == 0 )); then
        msg_debug "No previous update recorded."
        return 0
    fi

    if (( age > max_age_seconds )); then

        local days_ago=$(( age / 86400 ))

        msg_debug "Last update was ${days_ago} day(s) ago — update is due."

        return 0
    fi

    msg_debug "Last update is within threshold — no update required."

    return 1
}