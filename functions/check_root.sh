#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/InfoSec-Research/               #
#                                                         #
# File Name:   check_root.sh                              #
###########################################################

# The Kali Linux Setup Tool is designed to be executed as a standard user and not as the root user.
# It is aligned with the best practices of Kali Linux, which, in recent versions, defaults to a non-root user model (typically 'kali').
# Running as a standard user adheres to the principle of least privilege, enhancing overall system security by minimizing the risk of accidental or malicious system-wide changes.
# This approach is consistent with standard Linux practices, reducing the likelihood of compatibility issues with applications designed for non-privileged users.
# The script intelligently elevates privileges using 'sudo' for specific tasks that require higher permissions, thereby reducing the risk of unintentional system modifications or security breaches.
# This method of operation not only ensures a safer scripting environment but also educates users in security best practices by requiring conscious decisions to escalate privileges when necessary.
# Running this script as root will result in termination, as it is intended to encourage responsible system management and align with Kali Linux's focus on security and proper privilege management.

check_root() {
    if [ "$EUID" -eq 0 ]; then
        echo -e "\e[1;31m[*] ERROR [*]\e[0m\nThe Kali Linux Setup Tool is designed for new Kali Linux installations - the tool should be run without root privileges.\n\nThis process will now terminate...\n"
        exit 1
    fi
}