#!/usr/bin/env bash

###############################################################################
# File Name   : 01_core_errors.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.2
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Provides a global error trap, cleanup handler, and environment validation.
# Loaded immediately after 00_core_colours.sh so that all subsequent code
# benefits from structured error handling.
###############################################################################


# ─────────────────────────────────────────────────────────────────────────────
# Global error trap
# ─────────────────────────────────────────────────────────────────────────────
# Catches any unhandled error (non-zero exit) under `set -e` and prints a
# diagnostic before exiting. This replaces the default silent exit behaviour.

_error_trap() {

    local exit_code=$?
    local line_number="${BASH_LINENO[0]}"
    local command="${BASH_COMMAND}"
    local source_file="${BASH_SOURCE[1]:-unknown}"

    echo "" >&2
    msg_error "Unhandled error in ${CLR_BOLD}${source_file}${CLR_RESET} at line ${CLR_BOLD}${line_number}${CLR_RESET}"
    msg_error "Command: ${CLR_DIM}${command}${CLR_RESET}"
    msg_error "Exit code: ${exit_code}"
    echo "" >&2

    if type log_message &>/dev/null; then
        log_message "FATAL" "Unhandled error in ${source_file}:${line_number} — command: ${command} (exit ${exit_code})"
    fi

    # Perform cleanup before exiting
    _cleanup

    exit "$exit_code"
}

trap '_error_trap' ERR


# ─────────────────────────────────────────────────────────────────────────────
# Cleanup handler
# ─────────────────────────────────────────────────────────────────────────────
# Called on EXIT (normal or error). Modules may register additional cleanup
# tasks by appending commands to CLEANUP_TASKS.

declare -a CLEANUP_TASKS=()

_cleanup() {

    msg_debug "Running cleanup tasks..."

    for task in "${CLEANUP_TASKS[@]}"; do
        msg_debug "  Cleanup: $task"
        eval "$task" 2>/dev/null || true
    done

    # Always invalidate sudo timestamp on exit
    sudo -k 2>/dev/null || true

    msg_debug "Cleanup complete."
}

trap '_cleanup' EXIT


# ─────────────────────────────────────────────────────────────────────────────
# Environment validation
# ─────────────────────────────────────────────────────────────────────────────
# Ensures the runtime environment meets minimum requirements.

validate_environment() {

    # 1. Must be running under Bash
    if [[ -z "${BASH_VERSION:-}" ]]; then
        echo "[!] This script requires Bash. Attempting to re-exec..." >&2
        exec /bin/bash "$0" "$@"
    fi

    # 2. Minimum Bash version (4.0+ required for associative arrays)
    local bash_major="${BASH_VERSINFO[0]}"
    if (( bash_major < 4 )); then
        msg_fatal "Bash 4.0 or later is required (found ${BASH_VERSION})."
        exit 1
    fi

    # 3. Must NOT be root (principle of least privilege)
    if [[ "$EUID" -eq 0 ]]; then
        msg_fatal "This tool must not be run as ${CLR_RED}root${CLR_RESET}."
        echo "  It operates under the principle of least privilege and will"
        echo "  elevate with 'sudo' only when required."
        echo ""
        exit 1
    fi

    # 4. sudo must be available
    if ! command -v sudo &>/dev/null; then
        msg_fatal "'sudo' is not installed or not in PATH."
        exit 1
    fi

    # 5. Check essential commands are available
    local required_commands=("git" "apt" "dpkg" "date" "grep" "awk" "sed")
    local missing=()

    for cmd in "${required_commands[@]}"; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done

    if (( ${#missing[@]} > 0 )); then
        msg_fatal "Required commands not found: ${missing[*]}"
        echo "  Please install the missing dependencies and try again."
        exit 1
    fi

    msg_debug "Environment validation passed."
}


# ─────────────────────────────────────────────────────────────────────────────
# Dry-run command wrapper
# ─────────────────────────────────────────────────────────────────────────────
# Executes a command normally, or prints it if --dry-run is enabled.

run_cmd() {

    if [[ "${DRY_RUN:-false}" == true ]]; then
        msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} $*"
        return 0
    fi

    msg_debug "Executing: $*"
    "$@"
}