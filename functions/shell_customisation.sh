#!/usr/bin/env bash

###############################################################################
# File Name   : shell_customisation.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 1.1
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Manages zsh shell customisation via a ~/.zshrc.d/ snippet directory.
# Installs managed snippet files from templates and injects a sourcing
# block into ~/.zshrc so snippets are loaded automatically.
#
# Supports deploying to both the current user and root. Root deployment
# uses sudo for all file operations.
#
# Actions:
#   install       — Interactive prompt: current user only, or both?
#   install-user  — Explicit: current user only
#   install-all   — Explicit: current user + root
#   edit          — Open snippet directory in editor
#   remove        — Remove managed snippets and sourcing block (both targets)
###############################################################################

# Marker comments used to identify the managed sourcing block
readonly _ZSHRC_MARKER_START="# >>> kali-linux-setup-tool managed block >>>"
readonly _ZSHRC_MARKER_END="# <<< kali-linux-setup-tool managed block <<<"

# Scope flag — set during install, used by execution block
# Values: "user" or "all"
SHELL_CUSTOM_SCOPE=""


# ─────────────────────────────────────────────────────────────────────────────
# Resolve the template source directory for zshrc.d snippets
# ─────────────────────────────────────────────────────────────────────────────

_get_zshrc_template_dir() {
    echo "${TEMPLATE_DIR}/zshrc.d"
}


# ─────────────────────────────────────────────────────────────────────────────
# Helper: run a command, optionally via sudo for root targets
# ─────────────────────────────────────────────────────────────────────────────
# Usage: _target_cmd <target_home> command [args...]
# If target_home is /root, commands are run via sudo.

_target_cmd() {
    local target_home="$1"
    shift

    if [[ "$target_home" == "/root" ]]; then
        run_cmd sudo "$@"
    else
        run_cmd "$@"
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# Helper: read a file, optionally via sudo for root targets
# ─────────────────────────────────────────────────────────────────────────────

_target_cat() {
    local target_home="$1"
    local file="$2"

    if [[ "$target_home" == "/root" ]]; then
        sudo cat "$file"
    else
        cat "$file"
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# Helper: test if a file exists, optionally via sudo for root targets
# ─────────────────────────────────────────────────────────────────────────────

_target_file_exists() {
    local target_home="$1"
    local file="$2"

    if [[ "$target_home" == "/root" ]]; then
        sudo test -f "$file"
    else
        [[ -f "$file" ]]
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# Helper: test if a directory exists, optionally via sudo for root targets
# ─────────────────────────────────────────────────────────────────────────────

_target_dir_exists() {
    local target_home="$1"
    local dir="$2"

    if [[ "$target_home" == "/root" ]]; then
        sudo test -d "$dir"
    else
        [[ -d "$dir" ]]
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# Helper: label for output messages
# ─────────────────────────────────────────────────────────────────────────────

_target_label() {
    local target_home="$1"

    if [[ "$target_home" == "/root" ]]; then
        echo "root"
    else
        echo "${USER}"
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# Check whether the sourcing block is already present in a .zshrc
# ─────────────────────────────────────────────────────────────────────────────

_zshrc_block_present() {
    local target_home="$1"
    local zshrc="${target_home}/.zshrc"

    _target_file_exists "$target_home" "$zshrc" && \
        _target_cat "$target_home" "$zshrc" 2>/dev/null | grep -qF "$_ZSHRC_MARKER_START"
}


# ─────────────────────────────────────────────────────────────────────────────
# Inject the sourcing block into a .zshrc
# ─────────────────────────────────────────────────────────────────────────────

_inject_sourcing_block() {
    local target_home="$1"
    local zshrc="${target_home}/.zshrc"
    local label
    label="$(_target_label "$target_home")"

    if _zshrc_block_present "$target_home"; then
        msg_skip "Sourcing block already present in ${zshrc} (${label})."
        return 0
    fi

    msg_action "Adding snippet sourcing block to ${CLR_BOLD}${zshrc}${CLR_RESET} (${label})..."

    # The sourcing block uses $HOME which resolves correctly for each user
    local block
    block=$(cat <<'BLOCK'

# >>> kali-linux-setup-tool managed block >>>
# Loads all *.zsh snippets from ~/.zshrc.d/ — do not edit this block manually.
if [[ -d "${HOME}/.zshrc.d" ]]; then
    for _zshrc_snippet in "${HOME}"/.zshrc.d/*.zsh(N); do
        source "$_zshrc_snippet"
    done
    unset _zshrc_snippet
fi
# <<< kali-linux-setup-tool managed block <<<
BLOCK
)

    if [[ "${DRY_RUN:-false}" == true ]]; then
        msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would append sourcing block to ${zshrc} (${label})"
        return 0
    fi

    # Backup before modifying
    _target_cmd "$target_home" cp "$zshrc" "${zshrc}.bak.$(date +%Y%m%d%H%M%S)"
    msg_debug "Backed up ${zshrc}"

    # Append the block — use tee for root targets
    if [[ "$target_home" == "/root" ]]; then
        printf "%s\n" "$block" | sudo tee -a "$zshrc" >/dev/null
    else
        printf "%s\n" "$block" >> "$zshrc"
    fi

    msg_ok "Sourcing block added to ${zshrc} (${label})."
    log_message "INFO" "SHELL: Injected sourcing block into ${zshrc} (${label})"
}


# ─────────────────────────────────────────────────────────────────────────────
# Remove the sourcing block from a .zshrc
# ─────────────────────────────────────────────────────────────────────────────

_remove_sourcing_block() {
    local target_home="$1"
    local zshrc="${target_home}/.zshrc"
    local label
    label="$(_target_label "$target_home")"

    if ! _zshrc_block_present "$target_home"; then
        msg_skip "No managed sourcing block found in ${zshrc} (${label})."
        return 0
    fi

    msg_action "Removing sourcing block from ${CLR_BOLD}${zshrc}${CLR_RESET} (${label})..."

    if [[ "${DRY_RUN:-false}" == true ]]; then
        msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would remove sourcing block from ${zshrc} (${label})"
        return 0
    fi

    _target_cmd "$target_home" cp "$zshrc" "${zshrc}.bak.$(date +%Y%m%d%H%M%S)"

    # Use sed to delete from the start marker to the end marker (inclusive)
    _target_cmd "$target_home" sed -i "/${_ZSHRC_MARKER_START}/,/${_ZSHRC_MARKER_END}/d" "$zshrc"

    msg_ok "Sourcing block removed from ${zshrc} (${label})."
    log_message "INFO" "SHELL: Removed sourcing block from ${zshrc} (${label})"
}


# ─────────────────────────────────────────────────────────────────────────────
# Deploy snippet files from templates into a target's .zshrc.d/
# ─────────────────────────────────────────────────────────────────────────────

_deploy_snippets() {
    local target_home="$1"
    local snippet_dir="${target_home}/.zshrc.d"
    local label
    label="$(_target_label "$target_home")"

    local tpl_dir
    tpl_dir="$(_get_zshrc_template_dir)"

    if [[ ! -d "$tpl_dir" ]]; then
        msg_error "Snippet template directory not found: ${tpl_dir}"
        return 1
    fi

    _target_cmd "$target_home" mkdir -p "$snippet_dir"

    local deployed=0
    local skipped=0

    for tpl_file in "$tpl_dir"/*.zsh; do
        [[ -f "$tpl_file" ]] || continue

        local filename
        filename="$(basename "$tpl_file")"

        local target="${snippet_dir}/${filename}"

        if _target_file_exists "$target_home" "$target"; then

            # Compare contents — skip if identical
            if [[ "$target_home" == "/root" ]]; then
                if sudo diff -q "$tpl_file" "$target" &>/dev/null; then
                    msg_skip "${filename} is already up to date (${label})."
                    (( skipped++ ))
                    continue
                fi
            else
                if diff -q "$tpl_file" "$target" &>/dev/null; then
                    msg_skip "${filename} is already up to date (${label})."
                    (( skipped++ ))
                    continue
                fi
            fi

            # File exists and differs — ask the user
            msg_warn "${CLR_BOLD}${filename}${CLR_RESET} already exists and has been modified (${label})."
            printf "\n"
            printf "  %b1%b) Keep existing file (skip)\n" "${CLR_BOLD}" "${CLR_RESET}"
            printf "  %b2%b) Backup existing and replace with template\n" "${CLR_BOLD}" "${CLR_RESET}"
            printf "  %b3%b) View diff before deciding\n" "${CLR_BOLD}" "${CLR_RESET}"
            printf "\n"

            local choice=""
            while [[ "$choice" != "1" && "$choice" != "2" ]]; do

                read -r -p "  Choose [1/2/3]: " choice

                case "$choice" in
                    1)
                        msg_skip "Keeping existing ${filename} (${label})."
                        (( skipped++ ))
                        continue 2
                        ;;
                    2)
                        _target_cmd "$target_home" cp "$target" "${target}.bak.$(date +%Y%m%d%H%M%S)"
                        msg_debug "Backed up ${target}"
                        ;;
                    3)
                        printf "\n"
                        if [[ "$target_home" == "/root" ]]; then
                            sudo diff --color=auto -u "$target" "$tpl_file" || true
                        else
                            diff --color=auto -u "$target" "$tpl_file" || true
                        fi
                        printf "\n"
                        choice=""
                        ;;
                    *)
                        choice=""
                        ;;
                esac
            done
        fi

        if [[ "${DRY_RUN:-false}" == true ]]; then
            msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would install ${filename} → ${target} (${label})"
            (( deployed++ ))
            continue
        fi

        _target_cmd "$target_home" cp "$tpl_file" "$target"
        _target_cmd "$target_home" chmod 644 "$target"

        msg_ok "Installed ${CLR_BOLD}${filename}${CLR_RESET} (${label})"
        log_message "INFO" "SHELL: Deployed snippet ${filename} (${label})"
        (( deployed++ ))
    done

    printf "\n"
    msg_ok "Snippet deployment complete (${label})."
    msg_info "  Deployed: ${deployed}  |  Skipped: ${skipped}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Prompt user for deployment scope (interactive)
# ─────────────────────────────────────────────────────────────────────────────
# Returns the scope via SHELL_CUSTOM_SCOPE variable.
# Called once — either at the start of --all or when -r install runs.

shell_customisation_prompt_scope() {

    # If scope is already set (by an explicit action), skip the prompt
    [[ -n "$SHELL_CUSTOM_SCOPE" ]] && return 0

    printf "\n"
    msg_info "Shell customisation can be deployed to:"
    printf "\n"
    printf "  %b1%b) Current user only (%s)\n" "${CLR_BOLD}" "${CLR_RESET}" "${USER}"
    printf "  %b2%b) Current user (%s) ${CLR_BOLD}and${CLR_RESET} root\n" "${CLR_BOLD}" "${CLR_RESET}" "${USER}"
    printf "\n"

    local choice=""
    while [[ "$choice" != "1" && "$choice" != "2" ]]; do
        read -r -p "  Choose [1/2]: " choice
        case "$choice" in
            1) SHELL_CUSTOM_SCOPE="user" ;;
            2) SHELL_CUSTOM_SCOPE="all"  ;;
            *) choice="" ;;
        esac
    done

    printf "\n"
}


# ─────────────────────────────────────────────────────────────────────────────
# Internal: run install for a single target home directory
# ─────────────────────────────────────────────────────────────────────────────

_shell_install_for_target() {
    local target_home="$1"
    local label
    label="$(_target_label "$target_home")"

    msg_info "Deploying shell customisation snippets for ${CLR_BOLD}${label}${CLR_RESET}"
    printf "\n"

    # Show what will be installed
    local tpl_dir
    tpl_dir="$(_get_zshrc_template_dir)"

    msg_info "The following snippets will be managed:"
    printf "\n"

    for tpl_file in "$tpl_dir"/*.zsh; do
        [[ -f "$tpl_file" ]] || continue
        printf "    %s\n" "$(basename "$tpl_file")"
    done

    printf "\n"

    confirm_countdown 5 "Shell customisation for ${label} will begin" || return 0

    _deploy_snippets "$target_home"
    printf "\n"
    _inject_sourcing_block "$target_home"
}


# ─────────────────────────────────────────────────────────────────────────────
# Install action — deploy snippets + patch .zshrc for selected scope
# ─────────────────────────────────────────────────────────────────────────────

shell_customisation_install() {

    # Prompt for scope if not already set by an explicit action
    shell_customisation_prompt_scope

    # Show scope confirmation for explicit actions (no prompt was shown)
    if [[ "$SHELL_CUSTOM_SCOPE" == "all" ]]; then
        msg_info "Shell customisation will be deployed for ${CLR_BOLD}${USER}${CLR_RESET} and ${CLR_BOLD}root${CLR_RESET}."
    else
        msg_info "Shell customisation will be deployed for ${CLR_BOLD}${USER}${CLR_RESET} only."
    fi

    # Always deploy to current user
    _shell_install_for_target "$HOME"

    # Deploy to root if scope is "all"
    if [[ "$SHELL_CUSTOM_SCOPE" == "all" ]]; then
        printf "\n"
        _shell_install_for_target "/root"
    fi

    printf "\n"
    msg_ok "Shell customisation complete."
    msg_info "Run ${CLR_BOLD}exec zsh${CLR_RESET} or open a new terminal to apply changes."
}


# ─────────────────────────────────────────────────────────────────────────────
# Edit action — open snippet directory in editor
# ─────────────────────────────────────────────────────────────────────────────

shell_customisation_edit() {
    local snippet_dir="${HOME}/.zshrc.d"

    if [[ ! -d "$snippet_dir" ]]; then
        msg_warn "Snippet directory does not exist yet: ${snippet_dir}"
        msg_info "Run with ${CLR_BOLD}install${CLR_RESET} first to create it."
        return 1
    fi

    msg_info "Opening ${CLR_BOLD}${snippet_dir}${CLR_RESET} in ${EDITOR:-nano}..."

    "${EDITOR:-nano}" "$snippet_dir"/*.zsh
}


# ─────────────────────────────────────────────────────────────────────────────
# Internal: run removal for a single target home directory
# ─────────────────────────────────────────────────────────────────────────────

_shell_remove_for_target() {
    local target_home="$1"
    local snippet_dir="${target_home}/.zshrc.d"
    local label
    label="$(_target_label "$target_home")"

    _remove_sourcing_block "$target_home"

    if _target_dir_exists "$target_home" "$snippet_dir"; then

        msg_action "Removing snippet directory ${CLR_BOLD}${snippet_dir}${CLR_RESET} (${label})..."

        if [[ "${DRY_RUN:-false}" == true ]]; then
            msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would remove ${snippet_dir} (${label})"
        else
            _target_cmd "$target_home" rm -rf "$snippet_dir"
            msg_ok "Snippet directory removed (${label})."
            log_message "INFO" "SHELL: Removed snippet directory ${snippet_dir} (${label})"
        fi

    else
        msg_skip "No snippet directory found for ${label}."
    fi
}


# ─────────────────────────────────────────────────────────────────────────────
# Remove action — remove snippets and sourcing block from both targets
# ─────────────────────────────────────────────────────────────────────────────

shell_customisation_remove() {

    msg_warn "This will remove all managed shell customisation snippets."
    msg_info "Your original ${CLR_BOLD}.zshrc${CLR_RESET} files will have the sourcing block removed."
    printf "\n"

    confirm_countdown 5 "Removal will begin" || return 0

    # Always clean current user
    _shell_remove_for_target "$HOME"

    # Also clean root if snippets are present there
    if _target_dir_exists "/root" "/root/.zshrc.d" || _zshrc_block_present "/root"; then
        msg_info "Managed snippets detected for root — removing those too."
        _shell_remove_for_target "/root"
    fi

    printf "\n"
    msg_ok "Shell customisation removed."
    msg_info "Run ${CLR_BOLD}exec zsh${CLR_RESET} or open a new terminal to apply changes."
}
