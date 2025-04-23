#!/usr/bin/env bash

###############################################################################
# File Name   : git_import.sh                                                 #
# Author      : b3nn3tt@hbcomputersecurity.co.uk                              #
# Version     : 4.1                                                           #
# GitHub      : https://github.com/InfoSec-Research/                          #
#                                                                             #
# Description :                                                               #
# Clones or updates Git repositories listed in a structured CSV file.        #
# CSV Format: name,category,url,description                                   #
# Directory structure is auto-created under ~/github_repos/<category>/       #
###############################################################################

git_import() {
    readonly GIT="$HOME/github_repos"
    readonly REPO_LIST="$BASE_DIR/repositories/repository_list.csv"

    ##############################
    # Validate CSV Categories
    ##############################

    local VALID_CATEGORIES=(
        "1.OSINT"
        "2.Scanning"
        "3.Exploitation"
        "4.Post_Exploitation"
        "5.Exploit_Development"
        "6.Custom_Tools"
    )

    local INVALID_ENTRIES=()
    while IFS=',' read -r name category url description; do
        [[ "$name" == "name" ]] && continue  # skip header
        local valid=false
        for valid_cat in "${VALID_CATEGORIES[@]}"; do
            [[ "$category" == "$valid_cat" ]] && valid=true && break
        done
        if [[ "$valid" == false ]]; then
            INVALID_ENTRIES+=("$name,$category,$url,$description")
        fi
    done < "$REPO_LIST"

    if (( ${#INVALID_ENTRIES[@]} > 0 )); then
        echo -e "\n\e[1;31m[!! ERROR !!]\e[0m The following entries have invalid categories:
"
        for entry in "${INVALID_ENTRIES[@]}"; do
            echo -e "  → \e[91m$entry\e[0m"
        done
        echo -e "\nPlease update the CSV to match one of the following valid categories:"
        for cat in "${VALID_CATEGORIES[@]}"; do
            echo -e "  - $cat"
        done
        echo
        exit 1
    fi

    ##############################
    # Setup Git Directory Structure
    ##############################

    if [[ ! -d "$GIT" ]]; then
        echo -e "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Creating Git directory structure..."
        sleep 1

        for subdir in "${VALID_CATEGORIES[@]}"; do
            echo -e "[+] Creating $GIT/$subdir"
            mkdir -p "$GIT/$subdir"
            sleep 0.5
        done

        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Git folder structure created."
        sleep 1
    fi

    ##############################
    # Preview Repos to be Cloned
    ##############################

    echo -e "\n\e[1;34mThe following Git repositories will be cloned or updated:\e[0m\n"
    tail -n +2 "$REPO_LIST" | while IFS=',' read -r name dir repo_url description; do
        [[ -z "$name" || -z "$dir" || -z "$repo_url" ]] && continue
        echo -e "  [+] \e[1m$name\e[0m\n      ↳ \e[36m$dir\e[0m — \e[90m$description\e[0m\n"
    done

    echo -e "\nCloning will begin in 5 seconds — \e[1;31mpress any key to cancel\e[0m."
    if read -n 1 -s -r -t 5; then
        echo -e "\n[-] Operation cancelled."
        exit 1
    fi

    echo -e "\n\e[1;33;1m[>> STARTING GIT OPERATIONS <<]\e[0m\n"

    ##############################
    # Clone or Update Repos
    ##############################

    tail -n +2 "$REPO_LIST" | while IFS=',' read -r name dir repo_url description; do
        [[ -z "$name" || -z "$dir" || -z "$repo_url" ]] && continue

        local target_dir="$GIT/$dir/$name"

        if [[ ! -d "$target_dir" ]]; then
            echo -e "\n\e[1m$name\e[0m → \e[36m$dir\e[0m"
            echo -e "↳ \e[90m$description\e[0m\n"

            if git clone "$repo_url" "$target_dir"; then
                echo -e "\e[1;32m[++ COMPLETE ++]\e[0m $name cloned successfully."
                log_message "INFO" "GIT REPO CLONED: $name cloned successfully."
            else
                echo -e "\e[1;31m[!! ERROR !!]\e[0m Failed to clone $name. Moving on..."
                log_message "MINOR" "GIT CLONE ERROR: $name FAILED to clone."
            fi
        else
            echo -e "\n\e[1m$name\e[0m → \e[36m$dir\e[0m"
            echo -e "↳ \e[90m$description\e[0m"
            echo -e "\e[1;36m[== UPDATING ==]\e[0m Repository already exists — checking for updates..."

            pushd "$target_dir" >/dev/null

            if git_output=$(git pull 2>&1); then
                if echo "$git_output" | grep -q "Already up to date."; then
                    echo -e "\e[1;35m[-- SKIPPED --]\e[0m $name is already up to date."
                    log_message "INFO" "GIT REPO SKIPPED: $name already up to date."
                else
                    echo -e "\e[1;32m[++ UPDATED ++]\e[0m $name updated successfully."
                    log_message "INFO" "GIT REPO UPDATED: $name updated successfully."
                fi
            else
                echo -e "\e[1;31m[!! ERROR !!]\e[0m Failed to update $name."
                log_message "MINOR" "GIT UPDATE ERROR: $name FAILED to update."
            fi

            popd >/dev/null
        fi

        sleep 1
    done

    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Git operations completed."
    sleep 2
}
