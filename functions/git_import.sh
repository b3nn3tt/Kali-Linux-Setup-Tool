#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   git_import.sh                              #
# Description: Imports git repositories from a list file  #
#                                                         #
###########################################################

git_import(){
    # Checks if the required target directory structure is in place, and if not, creates it
    GIT="$HOME/github_repos"
    
    if [[ ! -e "$GIT" ]]; then
        echo -e "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Creating local git directory structure"
        sleep 3
        
        # Define an array of subdirectories
        SUBDIRS=(1.OSINT 2.Scanning 3.Exploitation 4.Post_Exploitation 5.Exploit_Development 6.Custom_Tools)
        
        # Create each subdirectory under $GIT
        for subdir in "${SUBDIRS[@]}"; do
            echo -e "\n[+] Creating $GIT/$subdir..."
            mkdir -p "$GIT/$subdir"
            sleep 1
        done
        echo -e "\n\n\e[1;32m[++ COMPLETE ++]\e[0m Directory structure created."
        sleep 3
    fi
    
    # Lists the contents of the repositories_list file, capturing what will be pulled from git
    REPO_LIST="$BASE_DIR/repositories/repository_list"
    
    echo -e "\nThe following git repositories will be cloned:\n"
    while IFS=' ' read -r name dir repo_url; do
        echo -e "[+] $name"
    done < "$REPO_LIST"
    
    echo -e "\nCloning will automatically commence in 5 seconds - \e[1;31mpress any key to cancel:\e[0m"
    if read -n 1 -s -r -t 5 -p ""; then
        echo -e "\n[-] Cloning cancelled"
        exit 1
    else
        echo -e "\nStarting cloning process...\n"
        
        # Checks to see if the repository has already been cloned. If not, then clone is performed. If so, then the repository is skipped
        while IFS=' ' read -r name dir repo_url; do
            if [[ ! -e "$GIT/$dir/$name" ]]; then
                echo -e "\n\e[1m$name\e[0m will now be cloned into \e[1;36m$dir\e[0m\n"
                
                # Attempt to clone and handle potential errors
                if git clone "$repo_url" "$GIT/$dir/$name"; then
                    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m $name cloned successfully."
                    log_message "INFO" "GIT REPO CLONED: $name cloned successfully."
                else
                    echo -e "\n\e[1;31m[!! ERROR !!]\e[0m Failed to clone $name. It may no longer exist or there could be a network issue. This error has been logged. Moving on..."
                    log_message "MINOR" "GIT CLONE ERROR: $name FAILED to clone."
                    sleep 2
                fi
                sleep 1
            else
                # Repository exists, checking for updates
            echo -e "\n\e[1;36m[== UPDATING ==]\e[0m Checking for updates in $name..."
            pushd "$GIT/$dir/$name" > /dev/null
            if git pull; then
                echo -e "\n\e[1;32m[++ UPDATED ++]\e[0m $name updated successfully."
                log_message "INFO" "GIT REPO UPDATED: $name updated successfully."
            else
                echo -e "\n\e[1;31m[!! ERROR !!]\e[0m Failed to update $name. Check for issues or network connectivity."
                log_message "MINOR" "GIT UPDATE ERROR: $name FAILED to update."
            fi
            popd > /dev/null
            fi
        done < "$REPO_LIST"
        
        sleep 3
        echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Git cloning is now complete."
        sleep 3
    fi
}
