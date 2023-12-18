#!/usr/bin/env bash

###########################################################
#                                                         #
# Author: b3nn3tt@hbcomputersecurity.co.uk                #
# Version: 1.0                                            #
# Git: https://github.com/b3nn3tt                         #
#                                                         #
# File Name:   desktop_environment_setup.sh               #
# Description: Customise the Kali Linux desktop           #
#              --------USE WITH CAUTION--------           #
#              At this time, this is a one way process    #
#                                                         #
###########################################################

desktop_environment_setup() {
    
    # Check for the presence of .desktop_complete
    if [ -f "$HOME/.desktop_complete" ]; then
        echo -e "\n\e[1;35m[-- ABORTING --]\e[0m Desktop customization is already in place - stopping further changes..."
        return
    fi
    
    # Pre-Installation disclaimer
    echo -e "\n\e[1;31m[!! WARNING !!]\e[0m You are about to configure a custom desktop environment. \e[1;31mThis process is currently IRREVERSIBLE\e[0m. Please ensure you wish to proceed."
    echo -e "\e[1;31mIMPORTANT: The system will REBOOT automatically after the application is complete.\e[0m"
    sleep 2
    echo -e "\nInstallation will commence in 5 seconds - \e[1;31mpress any key to abort:\e[0m"
    if read -n 1 -s -r -t 5; then
        echo -e "[-] Installation aborted"
        exit 1
    else
        printf "Starting installation...\n"
    fi
    
    # Configure UK Keyboard Layout as Default
    echo -e "\n\e[1;33;1m[.. PROCESSING ..]\e[0m Setting keymap to United Kingdom (gb)..."
    xfconf-query -c keyboard-layout -p /Default/XkbLayout -s gb --create -t string
    keymap=$(xfconf-query -c keyboard-layout -p /Default/XkbLayout)
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Keymap now set to \e[1;32m$keymap\e[0m"
    sleep 2
    
    # Package Dependency Installation
    echo -e "\e[1;33;1m[.. INSTALLING ..]\e[0m Installing desktop environment dependencies..."
    sudo apt install alsa-utils brightnessctl i3lock-color jq libgtk-layer-shell-dev libkeybinder-3.0-dev libstartup-notification0-dev libwnck-3-dev libxfce4panel-2.0-dev libxfce4ui-2-dev mugshot playerctl qt5-style-kvantum qt5-style-kvantum-themes xfce4-dev-tools xfce4-terminal -y
    echo -e "\e[1;32m[++ COMPLETE ++]\e[0m Desktop environment dependencies installed."
    sleep 2
    
    
    # Configure new terminal as default
    echo -e "\n\e[1;33;1m[.. CONFIGURING ..]\e[0m Configuring XFCE4 Terminal as the new default terminal..."
    sudo update-alternatives --set x-terminal-emulator /usr/bin/xfce4-terminal.wrapper
    xfconf-query -c xfce4-keyboard-shortcuts -p "/commands/custom/<Primary><Alt>t" -s "xfce4-terminal" --create -t string
    sleep 1
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m XFCE4 Terminal is now your default terminal."
    echo -e "\n\e[1;33;1m[.. CONFIGURING ..]\e[0m Removing qterminal as it is no longer required..."
    sudo apt remove qterminal -y
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m qterminal has been successfully uninstalled."
    sleep 2
    
    
    # Copying Initial Resources
    WORKING_DIR="$BASE_DIR/resources"
    
    # An alternative option to the below - (cd $WORKING_DIR && for z in $(ls *.zip | sort); do unzip "$z"; done)
    echo -e "\n\e[1;33;1m[** UNPACKING **]\e[0m Unpacking required configuration files - this may take a moment..."
    (cd $WORKING_DIR && unzip autostart-configs.zip && unzip findex-config.zip && unzip fonts.zip && unzip gtk-3.0-css.zip && unzip GTK-XFWM-Theme.zip && unzip home-config.zip && unzip i3lock-color-everblush.zip && unzip Kvantum-theme.zip && unzip Nordzy-cyan-dark-MOD.zip && unzip radioactive-nord.zip && unzip wallpapers.zip && unzip xfce4-config.zip)
    
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
    
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Configuration files have been successfully unpacked and installed."
    sleep 2
    
    # Appearance Config
    echo -e "\e[1;33;1m[.. CONFIGURING ..]\e[0m Applying your new desktop theme now - the appearance may be unusual until the system is restarted..."
    sleep 2
    xfconf-query -c xsettings -p /Net/ThemeName -s Everblush
    xfconf-query -c xsettings -p /Net/IconThemeName -s Nordzy-cyan-dark-MOD
    xfconf-query -c xsettings -p /Gtk/FontName -s "Roboto 10"
    xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "JetBrainsMono Nerd Font Mono 10"
    xfconf-query -c xfwm4 -p /general/theme -s Everblush-xfwm
    xfconf-query -c xsettings -p /Gtk/CursorThemeName -s Radioactive-nord
    xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVirtual1/workspace0/last-image -s "$HOME/.local/share/wallpapers/andre-benz-JBkwaYMuhdc-unsplash.jpg"
    xfconf-query -c xfce4-desktop -p /desktop-icons/style -s 0
    
    # GREETER Config
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
    
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Desktop theme has been successfully applied."
    sleep 2
    
    echo -e "\n\e[1;33;1m[.. CONFIGURING ..]\e[0m Adding desktop widgets. This process might take some time..."
    sleep 2
    
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
    
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Desktop widgets have been successfully installed."
    
    # Creation of Completion Artefact
    touch $HOME/.desktop_complete
    
    # Post config cleanup
    echo -e "\n\e[1;33;1m[.. CLEANING ..]\e[0m Removing installation artifacts that are no longer required..."
    sleep 2
    find $WORKING_DIR -mindepth 1 -type d -exec rm -rf {} +
    echo -e "\n\e[1;32m[++ COMPLETE ++]\e[0m Clean up complete."
    log_message "INFO" "CONFIGURATION: Desktop Customised."
    
    echo -e "\e[1;31m[!! SYSTEM RESTART !!]\e[0m Desktop customisation is now complete - the system will restart shortly to finalize the installation..."
    sleep 2
    sudo shutdown -r now
}