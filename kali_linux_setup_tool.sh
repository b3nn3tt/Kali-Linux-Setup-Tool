#!/bin/bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 2.0                                            #
# Git: https://github.com/InfoSec-Research/               #
#                                                         #
# File Name:   kali-linux-setup_tool.sh                   #
###########################################################

# Makes the script more robust and helps ensure that it fails quickly and gracefully if an error should occur
set -eo pipefail

# Constants, and frequently used variables
LOGDIR=~/.kali_setup/logs
LOG_FILE=$LOGDIR/log.txt

# ASCII art
ascii_art() {
    printf "%s\n"
    printf "\e[1;34m%s\e[0m\n" "               __ __      ___    __    _"
    printf "\e[1;34m%s\e[0m\n" "              / //_/___ _/ (_)  / /   (_)___  __  ___  __"
    printf "\e[1;34m%s\e[0m\n" "             / ,< / __ \`/ / /  / /   / / __ \/ / / / |/_/"
    printf "\e[1;34m%s\e[0m\n" "            / /| / /_/ / / /  / /___/ / / / / /_/ />  <"
    printf "\e[1;34m%s\e[0m\n" "           /_/ |_\__,_/_/_/  /_____/_/_/ /_/\__,_/_/|_|"
    printf "\e[1;34m%s\e[0m\n" "          _____      __                 ______            __"
    printf "\e[1;34m%s\e[0m\n" "         / ___/___  / /___  ______     /_  __/___  ____  / /"
    printf "\e[1;34m%s\e[0m\n" "         \__ \/ _ \/ __/ / / / __ \     / / / __ \/ __ \/ /"
    printf "\e[1;34m%s\e[0m\n" "        ___/ /  __/ /_/ /_/ / /_/ /    / / / /_/ / /_/ / /"
    printf "\e[1;34m%s\e[0m\n" "       /____/\___/\__/\__,_/ .___/    /_/  \____/\____/_/"
    printf "\e[1;34m%s\e[0m\n" "                          /_/"
    printf "%s\n"
    printf "\e[1;33;1m%s\e[0m\n" "                        -----------------"
    printf "\e[1;33;1m%s\e[0m\n" "                        |  Version 2.0  |"
    printf "\e[1;33;1m%s\e[0m\n" "                        -----------------"
    printf "\n\e[1;33;1m%sDescription: A tool to prepare Kali Linux for penetration testing.\e[0m\n"
    printf "%s\n"
}

# Script configures system for a standard user; it elevates via sudo where required. Running the script as root results in termination
check_root() {
    if [ "$EUID" = "0" ]; then
        ascii_art
        printf "\e[1;31m[*] ERROR [*]\e[0m\nThe Kali Linux Setup Tool is designed for new Kali Linux installations - the tool should be run without root privileges.\n\nThis process will now terminate...\n"
        exit
    fi
}

check_root

system_setup() {
    
    # Function to create log file and initial entry
    create_log() {
        [[ -d "$LOGDIR" ]] || mkdir -p "$LOGDIR"
        if [[ ! -e "$LOG_FILE" ]]; then
            touch "$LOG_FILE"
            printf "%s - Log Created\n" "$(date +'%Y-%m-%d %H:%M:%S')" > "$LOG_FILE"
        fi
    }
    
    # Function to perform system update
    perform_system_update() {
        printf "%s\n\n"
        printf "\e[1;33;1m%s[** PROCESSING **]\e[0m System update in progress...\n"
        sleep 3
        sudo apt update && sudo apt upgrade -y
        printf "%s - UPDATE: All default applications updated via apt\n" "$(date +'%Y-%m-%d %H:%M:%S')" >> "$LOG_FILE"
        printf "\n"
        printf "\e[1;32m[++ COMPLETE ++]\e[0mSystem update complete.\n"
        read -n 1 -s -r -p " Press any key to continue..."
        printf "\n\n"
        exit 0
    }
    
    if [ -f "$LOG_FILE" ]; then
        last_entry_date=$(tail -n 1 "$LOG_FILE" | awk '{print $1}')
        last_entry_timestamp=$(date -d "$last_entry_date" +%s)
        current_timestamp=$(date +%s)
        time_difference=$((current_timestamp - last_entry_timestamp))
        if [ "$time_difference" -gt $((7 * 24 * 60 * 60)) ]; then
            printf "\e[1;31m[!! WARNING !!]\e[0m Your system hasn't received updates within the past 7 days. To proceed, it's necessary to perform a comprehensive update of all installed packages.\n"
            read -n 1 -s -r -p "Please press any key to initiate the process:"
            perform_system_update
        fi
    else
        clear
        ascii_art
        printf "\e[1;32m[++ WELCOME ++]\e[0m It looks like this is the first time you have run the Kali Linux Setup Tool on your system. \nA full update of all installed packages is required to continue.\n\n"
        read -n 1 -s -r -p "Press any key to begin: "
        
        create_log
        perform_system_update
    fi
}

system_setup

# Usage message
usage() {
    #printf "Description: A tool to prepare Kali Linux for penetration testing.\n\n"
    printf "\n\e[1;33;1m%sUsage: $0 [OPTIONS]\e[0m"
    printf "\n\nOptions:\n"
    printf "  -a, --all           Run all options (excludes viewing logfiles)\n"
    printf "  -b, --banner        Display ASCII tool banner\n"
    printf "  -d, --desktop       Configure Custom Desktop Experience\n"
    printf "  -g, --git           Clone Github Repositories\n"
    printf "  -h, --help          Display this help message\n"
    printf "  -l, --log           View Logfiles\n"
    printf "  -p, --packages      Install Packages\n"
    printf "  -s, --sudo          Configure sudo to run without a password\n"
    printf "  -v, --version       Display tool version\n"
    printf "%s\n"
    printf "\e[1;33;1m%sExamples:\e[0m\n\n"
    printf "Install packages as defined in the static package list..."
    printf "\n$0 -p"
    printf "%s\n\n"
    printf "Edit the git repositories that will be cloned..."
    printf "\n$0 --git edit"
    printf "%s\n\n"
    printf "Perform git cloning and package installation"
    printf "\n$0 -g -p"
}

# Check for invalid option
check_invalid_option() {
    local valid_options="-a|--all -b|--banner -d|--desktop -g|--git -h|--help -l|--logs -p|--packages -s|--sudo -v|--version"  # List of valid options
    
    if [[ $1 =~ ^-[^-] ]]; then
        if ! [[ $valid_options =~ $1 ]]; then
            printf "Invalid option: %s\\n\\n" "$1" >&2
            usage
            exit 1
        fi
    else
        printf "Invalid option format: %s\\n" "$1" >&2
        usage
        exit 1
    fi
}

git_import() {
    # Checks if the required directory structure is in place, and if not, creates it
    GIT="$HOME/github_repos"
    
    if [[ ! -e "$GIT" ]]; then
        printf "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Creating local git directory structure\n"
        sleep 3
        
        # Define an array of subdirectories
        SUBDIRS=(1.OSINT 2.Scanning 3.Exploitation 4.Post_Exploitation 5.Exploit_Development 6.Custom_Tools)
        
        # Create each subdirectory under $GIT
        for subdir in "${SUBDIRS[@]}"; do
            printf "\n[+] Creating $GIT/$subdir..."
            mkdir -p "$GIT/$subdir"
            sleep 1
        done
        printf "\n\n\e[1;32m[++ COMPLETE ++]\e[0m Directory structure created.\n"
        sleep 3
    fi
    
    # Lists the contents of the repositories_list file, displaying what will be pulled from git
    REPO_LIST="./repositories/repository_list"
    
    printf "\nThe following git repositories will be cloned:\n\n"
    while IFS=' ' read -r name dir repo_url; do
        printf "[+] $name\n"
    done < "$REPO_LIST"
    
    printf "\nCloning will automatically commence in 5 seconds - \e[1;31mpress any key to cancel:\e[0m"
    if read -n 1 -s -r -t 5 -p ""; then
        printf "\n[-] Cloning cancelled\n"
        exit 1
    else
        printf "\nStarting cloning process...\n"
        
        # Checks to see if the repository has already been cloned. If not, then clone is performed. If so, then the repository is skipped
        while IFS=' ' read -r name dir repo_url; do
            if [[ ! -e "$GIT/$dir/$name" ]]; then
                printf "\n\e[1m$name\e[0m will now be cloned into \e[1;36m$dir\e[0m\n\n"
                
                # Attempt to clone and handle potential errors
                if git clone "$repo_url" "$GIT/$dir/$name"; then
                    printf "\n\e[1;32m[++ INSTALLED ++]\e[0m %s cloned successfully.\n" "$name"
                    printf "$(date +'%Y-%m-%d %H:%M:%S') - GIT REPO CLONED: %s cloned successfully.\n" "$name" >> $LOG_FILE
                else
                    printf "\n\e[1;31m[!! ERROR !!]\e[0m Failed to clone %s. It may no longer exist or there could be a network issue. This error has been logged. Moving on...\n" "$name"
                    printf "$(date +'%Y-%m-%d %H:%M:%S') - GIT CLONE ERROR: $name FAILED to clone.\n" >> $LOG_FILE
                    sleep 3
                fi
                
                sleep 1
            else
                printf "\n\e[1;35m[-- SKIPPING --]\e[0m $name has already been cloned. Skipping...\n"
                sleep 1
            fi
            
            
        done < "$REPO_LIST"
        
        sleep 3
        printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Git cloning is now complete.\n"
        sleep 3
    fi
}

package_install() {
    # Static list of packages to install
    PACKAGE_LIST="./packages/package_list"
    
    if [ ! -f "$PACKAGE_LIST" ]; then
        printf "\n\e[1;35m[** PACKAGE LIST NOT FOUND **]\e[0m %s\n" "$PACKAGE_LIST"
        exit 1
    fi
    
    # Add i386 Architecture - required for cross compiling / 32-Bit compatibility
    printf "\n\e[1;33;1m[.. CHECKING ..]\e[0m Verifying install status of i386 Architecture...\n"
    sleep 1
    if dpkg --print-foreign-architectures | grep -q i386; then
        printf "\e[1;35m[-- SKIPPING --]\e[0m i386 Architecture is already added.\n"
        sleep 1
    else
        printf "\n\e[1;31m[!! PACKAGE MISSING !!]\e[0m i386 Architecture support is not installed - adding now...\n"
        sleep 1
        sudo dpkg --add-architecture i386
        sudo apt update
        printf "\n\e[1;32m[++ COMPLETE ++]\e[0m i386 Architecture support installed successfully.\n"
        printf "$(date +'%Y-%m-%d %H:%M:%S') - ARCHITECTURE SUPPORT INSTALLED: i386 installed successfully.\n" >> $LOG_FILE
        sleep 1
    fi
    
    # Lists the contents of the packages_list file, displaying what will be installed via apt
    printf "\nThe following packages will be installed:\n\n"
    for packages in $(cat $PACKAGE_LIST); do
        printf "[+] $packages\n"
    done
    printf "%s\n"
    printf "Installation will automatically commence in 5 seconds - \e[1;31mpress any key to cancel:\e[0m\n"
    if read -n 1 -s -r -t 5 -p ""; then
        printf "[-] Installation cancelled"
        exit 1
    fi
    printf "Starting installation...\n"
    
    # Checks first to see if the package has already been installed. If not, then installation is performed. If so, then installation is skipped...
    while IFS= read -r required_package; do
        printf "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking install status of %s...\n" "$required_package"
        sleep 1
        
        if dpkg-query -W --showformat='${Status}\n' "$required_package" 2>/dev/null | grep -q "install ok installed"; then
            # Package is installed
            printf "\e[1;35m[-- SKIPPING --]\e[0m %s is already installed.\n" "$required_package"
            sleep 1
        else
            # Package is not installed
            printf "\n\e[1;31m[!! PACKAGE MISSING !!]\e[0m %s not found - installing now...\n\n" "$required_package"
            sleep 1
            # You can add the package installation command here
            sudo apt install -y "$required_package"
            printf "\n\e[1;32m[++ INSTALLED ++]\e[0m %s installed successfully.\n" "$required_package"
            printf "$(date +'%Y-%m-%d %H:%M:%S') - PACKAGE INSTALLED: %s installed successfully.\n" "$required_package" >> $LOG_FILE
            sleep 1
        fi
    done < "$PACKAGE_LIST"
    
    # Configures Veil Evasion post install
    if dpkg-query -W --showformat='${Status}\n' "veil" 2>/dev/null | grep -q "install ok installed"; then
        # Package is installed
        printf "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking install status of Veil..."
        sleep 1
        
        # Check if configuration has already been done by examining the log file - skips if alread configured
        if grep -q "CONFIGURATION: Veil" "$LOG_FILE"; then
            printf "\n\e[1;35m[-- SKIPPING --]\e[0m Veil has already been configured."
        else
            printf "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Veil has been installed but is not yet configured for use - configuring now..."
            sleep 1
            sudo /usr/share/veil/config/setup.sh --force --silent
            sleep 3
            printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration of Veil complete."
            printf "$(date +'%Y-%m-%d %H:%M:%S') - CONFIGURATION: Veil configuration script was run.\n" >> $LOG_FILE
        fi
    fi
    
    # PIP Section - Checks first to see if the package has already been installed. If not, then installation is performed. If so, then installation is skipped...
    
    # Static list of PIP packages to install
    PIP_PACKAGE_LIST=./packages/pip_package_list
    
    if [ ! -f "$PIP_PACKAGE_LIST" ]; then
        printf "\n\e[1;31m[** PIP PACKAGE LIST NOT FOUND **]\e[0m %s\n" "$PIP_PACKAGE_LIST"
        exit 1
    fi
    
    # Lists the contents of the packages_list file, displaying what will be installed via apt
    sleep 3
    printf "\n\nNext, the following PIP3 packages will be installed:\n\n"
    for packages in $(cat $PIP_PACKAGE_LIST); do
        printf "[+] $packages\n"
    done
    printf "%s\n"
    printf "Installation will automatically commence in 5 seconds - \e[1;31mpress any key to cancel:\e[0m\n"
    if read -n 1 -s -r -t 5 -p ""; then
        printf "[-] Installation cancelled"
        exit 1
    fi
    printf "Starting installation...\n"
    
    while IFS= read -r required_pippackage; do
        printf "\n\e[1;33;1m[.. CHECKING ..]\e[0m Checking install status of %s...\n" "$required_pippackage"
        sleep 1
        
        if pip3 list 2>/dev/null | grep -i "^$required_pippackage\s"; then
            # Package is installed
            printf "\e[1;35m[-- SKIPPING --]\e[0m %s is already installed.\n" "$required_pippackage"
            sleep 1
        else
            # Package is not installed
            printf "\n\e[1;31m[!! PACKAGE MISSING !!]\e[0m %s not found - installing now...\n\n" "$required_pippackage"
            sleep 1
            # You can add the package installation command here
            pip3 install $required_pippackage
            printf "\n\e[1;32m[++ INSTALLED ++]\e[0m %s installed successfully.\n" "$required_pippackage"
            printf "$(date +'%Y-%m-%d %H:%M:%S') - PIP3 PACKAGE INSTALLED: %s installed successfully.\n" "$required_pippackage" >> $LOG_FILE
            sleep 1
        fi
        
        sleep 3
        printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Tool installation and configuration is now complete.\n"
        sleep 3
        
    done < "$PIP_PACKAGE_LIST"
}

enable_sudo_pass(){
    
    printf "\n\e[1;32mThis will reactivate sudo password requirements\e[0m"
    sleep 3
    printf "\n\n\e[1;31msudo password will be reactivated in 5 seconds - press any key to cancel:\e[0m\n"
    
    # Wait for 5 seconds for a keypress; if a key is pressed, the script will exit the function
    if read -n 1 -s -r -t 5; then
        printf "\n[-] Operation cancelled\n"
        return
    fi
    
    # Check if the entry exists in the /etc/sudoers file
    if sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        # If the entry exist, remove it
        printf "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Modifying sudo configuration now..."
        sleep 3
        sudo sed -i "/^$USER ALL=(ALL) NOPASSWD:ALL$/d" /etc/sudoers
        printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration complete - you once again require a sudo password. Order has been restored"
        printf "$(date +'%Y-%m-%d %H:%M:%S') - CONFIGURATION: sudo password ENABLED.\n" >> $LOG_FILE
    else
        printf "\n\e[1;35m[-- SKIPPING --]\e[0m sudo password is already enabled for %s\n" "$USER"
    fi
}

disable_sudo_pass(){
    
    # Warning - makes clear that this is a purely convenience-driven option - not fit for a production system
    printf "\n\e[1;31m[** WARNING **]\e[0m This will allow you to use sudo without a password \e[1;31m[** WARNING **]\e[0m"
    sleep 3
    printf "\n\e[1;35mProceed with caution - this option is provided only for convenience during testing\e[0m"
    sleep 3
    printf "\n\n\e[1;31msudo password will be disabled in 5 seconds - press any key to cancel:\e[0m\n"
    
    # Wait for 5 seconds for a keypress; if a key is pressed, the script will exit the function
    if read -n 1 -s -r -t 5; then
        printf "\n[-] Operation cancelled\n"
        return
    fi
    
    # Check if the entry exists in the /etc/sudoers file
    if ! sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        # If the entry doesn't exist, append it
        printf "\n\e[1;33;1m[-- CONFIGURING --]\e[0m Modifying sudo configuration now..."
        sleep 3
        printf "%s ALL=(ALL) NOPASSWD:ALL\n" "$USER" | sudo tee -a /etc/sudoers
        printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration complete - you requires a sudo password no longer."
        printf "$(date +'%Y-%m-%d %H:%M:%S') - CONFIGURATION: sudo password DISABLED.\n" >> $LOG_FILE
    else
        printf "\n\e[1;35m[-- SKIPPING --]\e[0m sudo password is already disabled for %s\n" "$USER"
    fi
}

sudo_status() {
    # Check if the entry exists in the /etc/sudoers file
    if sudo grep -q "^$USER ALL=(ALL) NOPASSWD:ALL" /etc/sudoers; then
        printf "\n\e[1;32m[STATUS]\e[0m sudo password for %s is \e[1;31mDISABLED\e[0m. You have \e[1;31mP\e[1;32mH\e[1;33mE\e[1;34mN\e[1;35mO\e[1;36mM\e[1;37mI\e[1;31mN\e[1;32mA\e[1;33mL\e[1;34m \e[1;35mC\e[1;36mO\e[1;37mS\e[1;31mM\e[1;32mI\e[1;33mC\e[1;34m \e[1;35mP\e[1;36mO\e[1;37mW\e[1;31mE\e[1;32mR\e[0m!\n" "$USER"
        
    else
        printf "\n\e[1;32m[STATUS]\e[0m sudo password for %s is \e[1;32mENABLED\e[0m.\n" "$USER"
    fi
}

basic_desktop_setup() {
    
    # Check for the presence of .desktop_complete
    if [ -f "$HOME/.desktop_complete" ]; then
        echo "Desktop setup has already been completed. Exiting..."
        return
    fi
    
    # Pre-Installation disclaimer
    printf "%s\n"
    printf "\e[1;31m[!! WARNING!!]\e[0m You are about to configure a custom desktop environment. At present, this process is irreversable, so be certain before you proceed. \nInstallation will begin in 5 seconds - \e[1;31mpress any key to cancel:\e[0m\n"
    if read -n 1 -s -r -t 5 -p ""; then
        printf "[-] Installation cancelled"
        exit 1
    else
        printf "Starting installation...\n"
    fi
    
    # Configure UK Keyboard Layout as Default
    printf "\n\e[1;33;1m%s[** PROCESSING **]\e[0m Setting keymap to GB...\n"
    xfconf-query -c keyboard-layout -p /Default/XkbLayout -s GB --create -t string
    keymap=$(xfconf-query -c keyboard-layout -p /Default/XkbLayout)
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Process complete. Keymap now set to \e[1;32m$keymap\e[0m\n"
    sleep 3
    
    # Package Dependency Installation
    printf "\e[1;33;1m%s[** INSTALLING **]\e[0m Installing desktop environment dependencies...\n"
    sudo apt install alsa-utils brightnessctl i3lock-color jq libgtk-layer-shell-dev libkeybinder-3.0-dev libstartup-notification0-dev libwnck-3-dev libxfce4panel-2.0-dev libxfce4ui-2-dev mugshot playerctl qt5-style-kvantum qt5-style-kvantum-themes xfce4-dev-tools xfce4-terminal -y
    printf "\e[1;32m[++ COMPLETE ++]\e[0m Installation of dependencies complete.\n"
    sleep 3
    
    # Configure new terminal as default
    printf "\n\e[1;33;1m%s[** CONFIGURING **]\e[0m Configuring XFCE4 Terminal as new default terminal...\n"
    sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>t" -s "xfce4-terminal" --create -t string
    sleep 3
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m XFCE4 Terminal is now your defauilt terminal.\n"
    printf "\n\e[1;33;1m%s[** CONFIGURING **]\e[0m Removing qterminal as it is no longer required...\n"
    sudo apt remove qterminal -y
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m qterminal has been successfully uninstalled.\n"
    sleep 3
    
    # Copying Initial Resources
    WORKING_DIR="${PWD}/resources"
    
    printf "\n\e[1;33;1m%s[** UNPACKING **]\e[0m Unpacking required configuration files - this may take a moment...\n"
    (cd $WORKING_DIR && unzip autostart-configs.zip && unzip findex-config.zip && unzip fonts.zip && unzip gtk-3.0-css.zip && unzip GTK-XFWM-Theme.zip && unzip home-config.zip && unzip i3lock-color-everblush.zip && unzip Kvantum-theme.zip && unzip Nordzy-cyan-dark-MOD.zip && unzip radioactive-nord.zip && unzip wallpapers.zip && unzip xfce4-config.zip)
    
    # An alternative option to the above - (cd $WORKING_DIR && for z in $(ls *.zip | sort); do unzip "$z"; done)
    
    mkdir -p $HOME/.themes && mv $WORKING_DIR/GTK-XFWM-Everblush-Theme/* $HOME/.themes/
    
    mkdir -p $HOME/.local/share/icons && mv $WORKING_DIR/Nordzy-cyan-dark-MOD $HOME/.local/share/icons
    
    mv $WORKING_DIR/autostart $HOME/.config/
    
    mv $WORKING_DIR/findex $HOME/.config/
    
    mv $WORKING_DIR/fonts $HOME/.local/share/
    
    # mv $WORKING_DIR/genmon-scripts $HOME
    
    # mv $WORKING_DIR/gtk-3.0/gtk.css $HOME/.config/gtk-3.0/
    
    # mv $HOME/.profile $HOME/.profile.bk
    
    # mv $WORKING_DIR/home-config/.assets $HOME/
    
    # mv $WORKING_DIR/home-config/.profile $HOME/
    
    # mv $WORKING_DIR/home-config/.Xresources $HOME/
    
    mv $WORKING_DIR/Kvantum $HOME/.config/
    
    mv $WORKING_DIR/wallpapers $HOME/.local/share/
    
    # mv $HOME/.config/xfce4 $HOME/.config/xfce4.bk
    
    # mv $WORKING_DIR/xfce4 $HOME/.config/
    
    sudo cp -R $HOME/.themes/Everblush /usr/share/themes
    
    sudo cp -Rv $HOME/.local/share/icons/Nordzy-cyan-dark-MOD /usr/share/icons
    
    (cd $WORKING_DIR/Radioactive-nord/ && ./install.sh)
    
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration files successfully unpacked and installed.\n"
    sleep 3
    
    # Appearance Config
    printf "\e[1;33;1m%s[** CONFIGURING **]\e[0m Your new desktop theme will now be applied - this may look a little weird until the system has restarted...\n"
    sleep 3
    xfconf-query -c xsettings -p /Net/ThemeName -s Everblush
    xfconf-query -c xsettings -p /Net/IconThemeName -s Nordzy-cyan-dark-MOD
    xfconf-query -c xsettings -p /Gtk/FontName -s "Roboto 10"
    xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "JetBrainsMono Nerd Font Mono 10"
    xfconf-query -c xfwm4 -p /general/theme -s Everblush-xfwm
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s Radioactive-nord
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s "$HOME/.local/share/wallpapers/andre-benz-JBkwaYMuhdc-unsplash.jpg"
    xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0
    
    # GREETER CONF
    sudo cp /etc/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/lightdm-gtk-greeter.conf.bak
    sudo sed -i -e 's/theme-name = Kali-Light/theme-name = Everblush/g' \
    -e 's/icon-theme-name = Flat-Remix-Blue-Light/icon-theme-name = Nordzy-cyan-dark-MOD/g' \
    -e 's|background = /usr/share/desktop-base/kali-theme/login/background|background = #232A2D|g' \
    /etc/lightdm/lightdm-gtk-greeter.conf
    
    # Side Dock Configuration
    
    xfce4-panel --quit
    
    pkill xfconfd

    mv $HOME/.profile $HOME/.profile.bk

    mv $WORKING_DIR/home-config/.assets $HOME/
    
    mv $WORKING_DIR/home-config/.profile $HOME/
    
    mv $WORKING_DIR/home-config/.Xresources $HOME/
    
    mv $WORKING_DIR/gtk-3.0/gtk.css $HOME/.config/gtk-3.0/
    
    mv $WORKING_DIR/genmon-scripts $HOME
    
    mv $HOME/.config/xfce4 $HOME/.config/xfce4.bk
    
    mv $WORKING_DIR/xfce4 $HOME/.config/
    
    xfce4-panel &
    
    (cd $WORKING_DIR && git clone https://gitlab.xfce.org/panel-plugins/xfce4-docklike-plugin.git && cd xfce4-docklike-plugin && ./autogen.sh --prefix=/usr/local && make && sudo make install)
    
    sudo cp $WORKING_DIR/xfce4-docklike-plugin/src/docklike.desktop /usr/share/xfce4/panel/plugins
    sudo cp $WORKING_DIR/xfce4-docklike-plugin/src/.libs/libdocklike.so /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins
    sudo cp $WORKING_DIR/xfce4-docklike-plugin/src/libdocklike.la /usr/lib/x86_64-linux-gnu/xfce4/panel/plugins
    
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Desktop theme applied successfully.\n"
    sleep 3

    printf "\n\e[1;33;1m%s[** CONFIGURING **]\e[0m Adding desktop widgets. This may take a while...\n"
    sleep 3
    
    # eww Widget Configuration
    
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
    
    source $HOME/.cargo/env
    
    (cd $WORKING_DIR && git clone https://github.com/elkowar/eww.git && cd eww && cargo build --release)
    
    sudo mv $WORKING_DIR/eww/target/release/eww /usr/bin
    
    rm -rf $WORKING_DIR/eww
    
    (cd $WORKING_DIR && unzip eww-config.zip)
    
    mv $WORKING_DIR/eww $HOME/.config/
    
    eww open --toggle sidebar
    
    # Findex Configuration
    
    (cd $WORKING_DIR && git clone https://github.com/mdgaziur/findex.git && cd findex && ./installer.sh)
    
    # i3lock Configuration
    
    xfconf-query --create -c xfce4-session -p /general/LockCommand -t string -s "i3lock-everblush"
    
    sudo mv $WORKING_DIR/i3lock-color-everblush/i3lock-everblush /usr/bin/
    
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Desktop widgets have been successfully installed.\n"
    
    # Creation of Completion Artefact
    touch $HOME/.desktop_complete
    
    printf "\n\e[1;33;1m%s[** CLEANING **]\e[0m Removing installation artefacts that are no longer required...\n"
    sleep 3
    find $WORKING_DIR -mindepth 1 -type d -exec rm -rf {} +
    printf "\n\e[1;32m[++ COMPLETE ++]\e[0m Clean up complete.\n"
    
    printf "\e[1;31m[!! SYSTEM RESTART !!]\e[0m The process is now complete - the system will now restart to finalise the install...\n"
    sleep 3
    sudo shutdown -r now
}

# Default values
readonly DEFAULT_CLONE_GIT=false
readonly DEFAULT_CUSTOM_DESKTOP=false
readonly DEFAULT_GIT_ACTION=false
readonly DEFAULT_INSTALL_PACKAGES=false
readonly DEFAULT_PACKAGE_ACTION=false
readonly DEFAULT_SHOW_BANNER=false
readonly DEFAULT_SHOW_VERSION=false
readonly DEFAULT_SUDO_PASS=false
readonly DEFAULT_VIEW_LOGS=false

# Parse options
while [[ $# -gt 0 ]]; do
    
    case $1 in
        -a|--all)
            show_banner=true
            custom_desktop=true
            clone_git=true
            install_packages=true
            sudo_pass=true
            show_version=true
            shift
        ;;
        -b|--banner)
            show_banner=true
            shift
        ;;
        -d|--desktop)
            custom_desktop=true
            shift
        ;;
        -g|--git)
            clone_git=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                git_action="$2"
                shift 2
            else
                git_action="clone"
                shift
            fi
        ;;
        -h|--help)
            usage
            exit 0
        ;;
        -l|--log)
            view_log=true
            shift
        ;;
        -p|--packages)
            install_packages=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                package_action="$2"
                shift 2
            else
                package_action="add"
                shift
            fi
        ;;
        -s|--sudo)
            sudo_pass=true
            if [[ $# -gt 1 && ! $2 =~ ^- ]]; then
                sudo_action="$2"
                shift 2
            else
                package_action="status"
                shift
            fi
        ;;
        -v|--version)
            show_version=true
            shift
        ;;
        *)
            check_invalid_option "$1"
        ;;
    esac
done

# If no options are specified, display help
if [[ "$show_banner" != true && "$custom_desktop" != true && "$clone_git" != true && "$view_log" != true && "$install_packages" != true && "$sudo_pass" != true && "$show_version" != true ]]; then
    usage
    exit 1
fi

# Section for Banner Display
if [[ "$show_banner" = true ]]; then
    ascii_art
    show_version=false
fi

# Section for managing Git Repos
if [[ "$clone_git" = true ]]; then
    if [[ -z "$git_action" ]]; then
        git_action="clone"  # Set a default action if no action is provided
    fi
    
    case "$git_action" in
        clone)
            git_import
        ;;
        edit)
            # Set the default text editor to nano (you can replace 'nano' with your preferred editor, such as vi, emacs, or mousepad)
            export editor=nano
            $editor ./repositories/repository_list
        ;;
        delete)
            printf "Deleting Git Repos...\\n"
            # Add logic for deleting Git repositories here
        ;;
        *)
            printf "Invalid git action: %s\\n" "$git_action"
        ;;
    esac
    clone_git=false
fi

# Section for Custom Desktop
if [[ "$view_log" = true ]]; then
    less $LOG_FILE
    view_log=false
fi

# Section for managing Packages
if [[ "$install_packages" = true ]]; then
    if [[ -z "$package_action" ]]; then
        package_action="add"  # Set a default action if no action is provided
    fi
    
    case "$package_action" in
        add)
            package_install
        ;;
        edit)
            # Set the default text editor to nano (you can replace 'nano' with your preferred editor, such as vi, emacs, or mousepad)
            export editor=nano
            $editor ./packages/package_list
        ;;
        edit-pip)
            export editor=nano
            $editor ./packages/pip_package_list
        ;;
        *)
            printf "Invalid package action: %s\\n" "$package_action"
        ;;
    esac
    install_packages=false
fi

# Section for Sudo Password Configuration
if [[ "$sudo_pass" = true ]]; then
    if [[ -z "$sudo_action" ]]; then
        sudo_action="status"  # Set a default action if no action is provided
    fi
    
    case "$sudo_action" in
        status)
            sudo_status
        ;;
        reactivate)
            enable_sudo_pass
        ;;
        disable)
            disable_sudo_pass
        ;;
        *)
            printf "Invalid action: %s\\n" "$sudo_action"
        ;;
    esac
    sudo_pass=false
fi

# Section for Version Check
if [[ "$show_version" = true ]]; then
    printf "v2.0\\n"
    show_version=false
fi

# Section for Custom Desktop
if [[ "$custom_desktop" = true ]]; then
    basic_desktop_setup
    custom_desktop=false
fi
