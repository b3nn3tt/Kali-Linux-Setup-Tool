#!/usr/bin/env bash

###############################################################################
# File Name   : git_import.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 4.1
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Clones or updates Git repositories listed in a structured CSV file.
# CSV Format: name,category,url,description
# Directory structure is auto-created under ~/github_repos/<category>/
###############################################################################

readonly VALID_GIT_CATEGORIES=(
    "1.OSINT"
    "2.Scanning"
    "3.Exploitation"
    "4.Post_Exploitation"
    "5.Exploit_Development"
    "6.Custom_Tools"
)

git_import() {

    local git_base="$HOME/github_repos"
    local repo_list="${REPO_LIST}"

    # ─── Validate CSV exists ──────────────────────────────────────────────
    if [[ ! -f "$repo_list" ]]; then
        msg_error "Repository list not found at: ${repo_list}"
        msg_info  "Create one with format: name,category,url,description"
        return 1
    fi

    # ─── Validate categories ──────────────────────────────────────────────
    local invalid_entries=()

    while IFS=',' read -r name category url description; do

        [[ "$name" == "name" ]] && continue
        [[ -z "$name" ]] && continue

        local valid=false

        for valid_cat in "${VALID_GIT_CATEGORIES[@]}"; do
            [[ "$category" == "$valid_cat" ]] && valid=true && break
        done

        if [[ "$valid" == false ]]; then
            invalid_entries+=("${name} → ${category}")
        fi

    done < "$repo_list"

    if (( ${#invalid_entries[@]} > 0 )); then

        msg_error "The following entries have invalid categories:"

        for entry in "${invalid_entries[@]}"; do
            printf "    %s\n" "$entry"
        done

        printf "\n"
        msg_info "Valid categories:"

        for cat in "${VALID_GIT_CATEGORIES[@]}"; do
            printf "    %s\n" "$cat"
        done

        return 1
    fi

    # ─── Ensure directory structure exists ─────────────────────────────────
    msg_action "Ensuring Git directory structure exists..."

    for subdir in "${VALID_GIT_CATEGORIES[@]}"; do
        run_cmd mkdir -p "${git_base}/${subdir}"
    done

    msg_ok "Git folder structure ready."

    # ─── Preview repositories ──────────────────────────────────────────────
    msg_info "The following repositories will be cloned or updated:"
    printf "\n"

    while IFS=',' read -r name dir repo_url description; do

        [[ "$name" == "name" ]] && continue
        [[ -z "$name" || -z "$dir" || -z "$repo_url" ]] && continue

        printf "  %b%s%b  →  %b%s%b\n" \
            "${CLR_BOLD}" "$name" "${CLR_RESET}" \
            "${CLR_CYAN}" "$dir" "${CLR_RESET}"

        printf "    %b%s%b\n" \
            "${CLR_DIM_GREY}" "$description" "${CLR_RESET}"

    done < "$repo_list"

    printf "\n"

    confirm_countdown 5 "Git operations will begin" || return 0

    # ─── Clone or update repositories ─────────────────────────────────────
    msg_action "Starting Git operations..."
    printf "\n"

    while IFS=',' read -r name dir repo_url description; do

        [[ "$name" == "name" ]] && continue
        [[ -z "$name" || -z "$dir" || -z "$repo_url" ]] && continue

        local target_dir="${git_base}/${dir}/${name}"

        if [[ ! -d "$target_dir" ]]; then

            msg_action "Cloning ${CLR_BOLD}${name}${CLR_RESET}..."

            if run_cmd git clone "$repo_url" "$target_dir"; then
                msg_ok "${name} cloned successfully."
                log_message "INFO" "GIT REPO CLONED: ${name}"
            else
                msg_error "Failed to clone ${name} — skipping."
                log_message "ERROR" "GIT CLONE FAILED: ${name}"
            fi

        else

            msg_action "Checking ${CLR_BOLD}${name}${CLR_RESET} for updates..."

            # Respect --dry-run for pull operations
            if [[ "${DRY_RUN:-false}" == true ]]; then
                msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} Would pull updates for ${name}"
                continue
            fi

            pushd "$target_dir" >/dev/null || continue

            if git_output=$(git pull 2>&1); then

                if echo "$git_output" | grep -q "Already up to date."; then
                    msg_skip "${name} is already up to date."
                    log_message "INFO" "GIT REPO SKIPPED: ${name} (up to date)"
                else
                    msg_ok "${name} updated successfully."
                    log_message "INFO" "GIT REPO UPDATED: ${name}"
                fi

            else
                msg_error "Failed to update ${name}."
                log_message "ERROR" "GIT UPDATE FAILED: ${name}"
            fi

            popd >/dev/null || true
        fi

    done < "$repo_list"

    msg_ok "Git operations completed."
}


git_delete() {

    local git_base="$HOME/github_repos"

    if [[ ! -d "$git_base" ]]; then
        msg_warn "No Git repository directory found at ${git_base}. Nothing to delete."
        return 0
    fi

    msg_warn "This will ${CLR_RED}permanently delete${CLR_RESET} all cloned repositories in:"
    printf "    %s\n\n" "${git_base}"

    confirm_countdown 5 "Deletion will begin" || return 0

    run_cmd rm -rf "$git_base"

    msg_ok "All managed repositories deleted."
    log_message "WARNING" "GIT REPOS DELETED: ${git_base} removed."
}