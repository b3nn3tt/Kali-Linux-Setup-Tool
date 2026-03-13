#!/usr/bin/env bash

###############################################################################
# File Name   : 00_core_paths.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.2
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Resolves all directory paths used by the tool. Supports two modes:
#
#   1. INSTALLED — tool lives in /usr/local/bin, shared data in
#      /usr/local/share/kali-linux-setup-tool, user config in
#      ~/.config/kali-linux-setup-tool, user data (logs, state) in
#      ~/.local/share/kali-linux-setup-tool.
#
#   2. DEV CHECKOUT — a functions/ directory exists next to the script,
#      so everything is resolved relative to the script location. This lets
#      you develop and test without installing.
#
# Detection logic: if $SCRIPT_DIR/functions/ exists, we're in dev mode.
#
# All modules should reference these variables rather than constructing
# their own paths.
###############################################################################


# ─────────────────────────────────────────────────────────────────────────────
# Guard against double-sourcing
# ─────────────────────────────────────────────────────────────────────────────

[[ -n "${_CORE_PATHS_LOADED:-}" ]] && return 0
readonly _CORE_PATHS_LOADED=1


# ─────────────────────────────────────────────────────────────────────────────
# Determine script location
# ─────────────────────────────────────────────────────────────────────────────

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"


# ─────────────────────────────────────────────────────────────────────────────
# Detect runtime mode
# ─────────────────────────────────────────────────────────────────────────────

if [[ -d "${SCRIPT_DIR}/functions" ]]; then

    # ── DEV CHECKOUT MODE ────────────────────────────────────────────────────

    readonly KALI_SETUP_MODE="dev"

    readonly FUNC_DIR="${SCRIPT_DIR}/functions"
    readonly RESOURCES_DIR="${SCRIPT_DIR}/resources"
    readonly TEMPLATE_DIR="${SCRIPT_DIR}/templates"

    readonly CONFIG_DIR="${SCRIPT_DIR}"
    readonly DATA_DIR="${SCRIPT_DIR}"

    readonly LOG_DIR="${SCRIPT_DIR}/logs"
    readonly STATE_DIR="${SCRIPT_DIR}/state"

    # In dev mode, config files live directly in templates/
    readonly REPO_LIST="${TEMPLATE_DIR}/repository_list.csv"
    readonly PACKAGE_LIST="${TEMPLATE_DIR}/package_list.txt"

else

    # ── INSTALLED MODE ───────────────────────────────────────────────────────

    readonly KALI_SETUP_MODE="installed"

    # Determine installation prefix from script location
    # Script is at $PREFIX/bin/kali_linux_setup_tool.sh, so one dirname
    # from SCRIPT_DIR ($PREFIX/bin) gives us $PREFIX
    INSTALL_PREFIX="$(dirname "$SCRIPT_DIR")"

    readonly SHARE_DIR="${INSTALL_PREFIX}/share/kali-linux-setup-tool"
    readonly FUNC_DIR="${SHARE_DIR}/functions"
    readonly RESOURCES_DIR="${SHARE_DIR}/resources"
    readonly TEMPLATE_DIR="${SHARE_DIR}/templates"

    # XDG directories with sensible defaults
    readonly CONFIG_DIR="${XDG_CONFIG_HOME:-${HOME}/.config}/kali-linux-setup-tool"
    readonly DATA_DIR="${XDG_DATA_HOME:-${HOME}/.local/share}/kali-linux-setup-tool"

    readonly LOG_DIR="${DATA_DIR}/logs"
    readonly STATE_DIR="${DATA_DIR}/state"

    # In installed mode, config files live in user XDG config directories
    readonly REPO_LIST="${CONFIG_DIR}/repositories/repository_list.csv"
    readonly PACKAGE_LIST="${CONFIG_DIR}/packages/package_list.txt"

fi


# ─────────────────────────────────────────────────────────────────────────────
# Derived paths (mode-independent)
# ─────────────────────────────────────────────────────────────────────────────

readonly LOG_FILE="${LOG_DIR}/log.txt"