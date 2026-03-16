#!/usr/bin/env bash

###############################################################################
# Kali Linux Setup Tool v4.2
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# A modular CLI tool to prepare Kali Linux for penetration testing.
# Manages system updates, APT packages, Git repositories, sudo behaviour,
# and desktop customisation.
#
# Usage       : ./kali_linux_setup_tool.sh [OPTIONS]
#               Run with --help for full usage information.
###############################################################################

# ─── Strict mode ─────────────────────────────────────────────────────────────
set -euo pipefail
IFS=$'\n\t'


##############################
#     GLOBAL CONSTANTS       #
##############################

readonly APP_NAME="Kali Linux Setup Tool"
readonly APP_VERSION="4.2"


##############################
#  GLOBAL RUNTIME FLAGS      #
##############################

DRY_RUN=false
VERBOSE=false
QUIET=false


##############################
#     PATH RESOLUTION        #
##############################

SCRIPT_PATH="$(readlink -f "$0")"
SCRIPT_DIR="$(dirname "$SCRIPT_PATH")"

if [[ -d "${SCRIPT_DIR}/functions" ]]; then
    # DEV CHECKOUT MODE
    _BOOTSTRAP_FUNC_DIR="${SCRIPT_DIR}/functions"
else
    # INSTALLED MODE
    INSTALL_PREFIX="$(dirname "$SCRIPT_DIR")"
    _BOOTSTRAP_FUNC_DIR="${INSTALL_PREFIX}/share/kali-linux-setup-tool/functions"
fi

if [[ ! -f "${_BOOTSTRAP_FUNC_DIR}/00_core_paths.sh" ]]; then
    printf "\n" >&2
    printf "[!! FATAL !!] Cannot locate core framework file:\n" >&2
    printf "             %s\n" "${_BOOTSTRAP_FUNC_DIR}/00_core_paths.sh" >&2
    printf "\n" >&2
    printf "Possible causes:\n" >&2
    printf "  • The tool is not installed correctly\n" >&2
    printf "  • The install prefix changed\n" >&2
    printf "  • Running from a partial source checkout\n" >&2
    printf "\n" >&2
    printf "Try reinstalling:\n" >&2
    printf "  sudo make install\n" >&2
    printf "\n" >&2
    exit 1
fi

# shellcheck source=functions/00_core_paths.sh
source "${_BOOTSTRAP_FUNC_DIR}/00_core_paths.sh"
unset _BOOTSTRAP_FUNC_DIR


##############################
#  LOAD FUNCTION FILES       #
##############################

_load_functions() {
    local loaded=0
    local failed=0

    if [[ ! -d "$FUNC_DIR" ]]; then
        printf "[!! FATAL !!] Functions directory not found: %s\n" "${FUNC_DIR}" >&2
        exit 1
    fi

    for func_file in "$FUNC_DIR"/*.sh; do
        [[ -f "$func_file" ]] || continue

        if ! source "$func_file"; then
            printf "[!! ERROR !!] Failed to source: %s\n" "${func_file}" >&2
            ((failed+=1))
        else
            ((loaded+=1))
        fi
    done

    if (( failed > 0 )); then
        printf "[!! FATAL !!] %s function file(s) failed to load.\n" "${failed}" >&2
        exit 1
    fi

    if type msg_debug &>/dev/null; then
        msg_debug "Loaded ${loaded} function file(s) from ${FUNC_DIR}"
    fi
}

_load_functions


##############################
#  ENVIRONMENT VALIDATION    #
##############################

validate_environment


##############################
#  INITIALISE LOGGING        #
##############################

init_logging


##############################
#  ENSURE USER CONFIG EXISTS #
##############################

if [[ "${KALI_SETUP_MODE}" == "installed" ]]; then

    mkdir -p "${CONFIG_DIR}/packages"
    mkdir -p "${CONFIG_DIR}/repositories"

    # Copy package template on first run
    if [[ ! -f "${PACKAGE_LIST}" && -f "${TEMPLATE_DIR}/package_list.txt" ]]; then
        cp "${TEMPLATE_DIR}/package_list.txt" "${PACKAGE_LIST}"
        msg_debug "Seeded default package list from template."
    fi

    # Copy repository template on first run
    if [[ ! -f "${REPO_LIST}" && -f "${TEMPLATE_DIR}/repository_list.csv" ]]; then
        cp "${TEMPLATE_DIR}/repository_list.csv" "${REPO_LIST}"
        msg_debug "Seeded repository list from template."
    fi

fi


##############################
#     DEFAULT FLAG STATES    #
##############################

declare -A MODULES=(
    [banner]=false
    [desktop]=false
    [git]=false
    [log]=false
    [packages]=false
    [shell]=false
    [sudo]=false
    [version]=false
    [update]=false
)

declare -A MODULE_ACTIONS=()


##############################
#      PARSE CLI OPTIONS     #
##############################

_parse_cli() {
    while [[ $# -gt 0 ]]; do
        case "$1" in

            -a|--all)
                MODULES[banner]=true
                MODULES[desktop]=true
                MODULES[git]=true
                MODULE_ACTIONS[git]="clone"
                MODULES[packages]=true
                MODULE_ACTIONS[packages]="install"
                MODULES[shell]=true
                MODULE_ACTIONS[shell]="install"
                MODULES[sudo]=true
                MODULE_ACTIONS[sudo]="status"
                MODULES[version]=true
                shift
                ;;

            -b|--banner)
                MODULES[banner]=true
                shift
                ;;

            -d|--desktop)
                MODULES[desktop]=true
                shift
                ;;

            -g|--git)
                MODULES[git]=true
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                    MODULE_ACTIONS[git]="$2"
                    shift 2
                else
                    show_git_usage
                    exit 1
                fi
                ;;

            -h|--help)
                show_usage
                exit 0
                ;;

            -l|--log)
                MODULES[log]=true
                shift
                ;;

            -p|--packages)
                MODULES[packages]=true
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                    MODULE_ACTIONS[packages]="$2"
                    shift 2
                else
                    show_package_usage
                    exit 1
                fi
                ;;

            -r|--rcsetup)
                MODULES[shell]=true
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                    MODULE_ACTIONS[shell]="$2"
                    shift 2
                else
                    show_shell_usage
                    exit 1
                fi
                ;;

            -s|--sudo)
                MODULES[sudo]=true
                if [[ $# -gt 1 && ! "$2" =~ ^- ]]; then
                    MODULE_ACTIONS[sudo]="$2"
                    shift 2
                else
                    show_sudo_usage
                    exit 1
                fi
                ;;

            -u|--update)
                MODULES[update]=true
                shift
                ;;

            -v|--version)
                MODULES[version]=true
                shift
                ;;

            --paths)
                printf "\n"
                printf "  Mode:        %s\n" "${KALI_SETUP_MODE}"
                printf "  Functions:   %s\n" "${FUNC_DIR}"
                printf "  Resources:   %s\n" "${RESOURCES_DIR}"
                printf "  Templates:   %s\n" "${TEMPLATE_DIR}"
                printf "  Config:      %s\n" "${CONFIG_DIR}"
                printf "  Packages:    %s\n" "${PACKAGE_LIST}"
                printf "  Repo list:   %s\n" "${REPO_LIST}"
                printf "  Logs:        %s\n" "${LOG_DIR}"
                printf "  State:       %s\n" "${STATE_DIR}"
                printf "\n"
                exit 0
                ;;

            --dry-run)
                DRY_RUN=true
                shift
                ;;

            --verbose)
                VERBOSE=true
                shift
                ;;

            --quiet|-q)
                QUIET=true
                shift
                ;;

            *)
                msg_error "Invalid option: ${CLR_BOLD}${1}${CLR_RESET}"
                printf "\n"
                show_usage
                exit 1
                ;;
        esac
    done
}

_parse_cli "$@"


##############################
#  SHOW USAGE IF NO OPTIONS  #
##############################

_any_module_active() {
    for key in "${!MODULES[@]}"; do
        [[ "${MODULES[$key]}" == true ]] && return 0
    done
    return 1
}

if ! _any_module_active; then
    display_banner
    show_usage
    exit 0
fi


##############################
#  UP-FRONT INTERACTIVE      #
#  PROMPTS (for --all mode)  #
##############################

# When --all is used, gather any interactive choices before modules run
# so the user isn't interrupted mid-flow.
# Only prompt when the action is "install" (interactive) — explicit actions
# (install-user, install-all) and non-install actions (edit, remove) skip this.

if [[ "${MODULES[shell]}" == true && "${MODULE_ACTIONS[shell]:-}" == "install" && -z "${SHELL_CUSTOM_SCOPE}" ]]; then
    shell_customisation_prompt_scope
fi


##############################
#    CHECK FOR UPDATES       #
##############################

if [[ "${MODULES[update]}" == true ]]; then
    if ! perform_system_update; then
        msg_error "System update failed."
    fi
elif [[ "${QUIET}" != true && "${DRY_RUN}" != true ]]; then

    if is_first_run; then
        # First run — no update has ever been recorded; insist on running one
        msg_warn "No previous system update recorded — this appears to be a first run."
        printf "  A full system update is required before continuing.\n"
        printf "\n"

        if ! perform_system_update; then
            msg_error "System update failed."
            exit 1
        fi

    elif is_update_due; then
        # Stamp file exists but is older than 7 days — recommend but don't force
        msg_warn "It has been over 7 days since the last system update."
        printf "  A full update is recommended before continuing.\n"
        printf "\n"
        read -r -p "  Run update now? [y/N]: " response
        if [[ "${response,,}" == "y" ]]; then
            if ! perform_system_update; then
                msg_error "System update failed."
            fi
        else
            msg_info "Skipping update — continuing with current packages."
        fi
    fi

fi


##############################
#     EXECUTION BLOCKS       #
##############################

# ─── Banner ──────────────────────────────────────────────────────────────────
if [[ "${MODULES[banner]}" == true ]]; then
    if ! display_banner; then
        msg_error "Banner module failed."
    fi
    MODULES[banner]=false
    MODULES[version]=false
fi

# ─── Version ─────────────────────────────────────────────────────────────────
if [[ "${MODULES[version]}" == true ]]; then
    printf "v%s\n" "${APP_VERSION}"
    MODULES[version]=false
fi

# ─── Log viewer ──────────────────────────────────────────────────────────────
if [[ "${MODULES[log]}" == true ]]; then
    if [[ -f "$LOG_FILE" ]]; then
        less "$LOG_FILE"
    else
        msg_warn "No log file found at ${LOG_FILE}"
    fi
    MODULES[log]=false
fi

# ─── Git operations ──────────────────────────────────────────────────────────
if [[ "${MODULES[git]}" == true ]]; then
    print_section "Git Repository Management"

    case "${MODULE_ACTIONS[git]:-}" in
        clone)
            if ! git_import; then
                msg_error "Git module failed."
            fi
            ;;
        edit)
            "${EDITOR:-nano}" "${REPO_LIST}"
            ;;
        delete)
            if ! git_delete; then
                msg_error "Git delete operation failed."
            fi
            ;;
        *)
            msg_error "Unknown git action: ${MODULE_ACTIONS[git]:-<none>}"
            show_git_usage
            ;;
    esac
    MODULES[git]=false
fi

# ─── Package installation ────────────────────────────────────────────────────
if [[ "${MODULES[packages]}" == true ]]; then
    print_section "APT Package Management"

    case "${MODULE_ACTIONS[packages]:-}" in
        install)
            if ! package_install; then
                msg_error "Package module failed."
            fi
            ;;
        edit)
            "${EDITOR:-nano}" "${PACKAGE_LIST}"
            ;;
        *)
            msg_error "Unknown package action: ${MODULE_ACTIONS[packages]:-<none>}"
            show_package_usage
            ;;
    esac
    MODULES[packages]=false
fi

# ─── Sudo management ─────────────────────────────────────────────────────────
if [[ "${MODULES[sudo]}" == true ]]; then
    print_section "Sudo Configuration"

    case "${MODULE_ACTIONS[sudo]:-}" in
        status)
            if ! sudo_status; then
                msg_error "Sudo status check failed."
            fi
            ;;
        activate)
            if ! enable_sudo_pass; then
                msg_error "Failed to re-enable sudo password prompts."
            fi
            ;;
        disable)
            if ! disable_sudo_pass; then
                msg_error "Failed to disable sudo password prompts."
            fi
            ;;
        *)
            msg_error "Unknown sudo action: ${MODULE_ACTIONS[sudo]:-<none>}"
            show_sudo_usage
            ;;
    esac
    MODULES[sudo]=false
fi

# ─── Shell customisation ────────────────────────────────────────────────────
if [[ "${MODULES[shell]}" == true ]]; then
    print_section "Shell Customisation"

    case "${MODULE_ACTIONS[shell]:-}" in
        install)
            if ! shell_customisation_install; then
                msg_error "Shell customisation module failed."
            fi
            ;;
        install-user)
            SHELL_CUSTOM_SCOPE="user"
            if ! shell_customisation_install; then
                msg_error "Shell customisation module failed."
            fi
            ;;
        install-all)
            SHELL_CUSTOM_SCOPE="all"
            if ! shell_customisation_install; then
                msg_error "Shell customisation module failed."
            fi
            ;;
        edit)
            shell_customisation_edit
            ;;
        remove)
            if ! shell_customisation_remove; then
                msg_error "Shell customisation removal failed."
            fi
            ;;
        *)
            msg_error "Unknown shell action: ${MODULE_ACTIONS[shell]:-<none>}"
            show_shell_usage
            ;;
    esac
    MODULES[shell]=false
fi

# ─── Desktop customisation ───────────────────────────────────────────────────
if [[ "${MODULES[desktop]}" == true ]]; then
    print_section "Desktop Customisation"
    if ! desktop_environment_setup; then
        msg_error "Desktop module failed."
    fi
    MODULES[desktop]=false
fi

msg_debug "All requested operations complete."