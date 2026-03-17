#!/usr/bin/env bash

###############################################################################
# File Name   : desktop_environment_setup.sh
# Author      : b3nn3tt@hbcomputersecurity.co.uk
# Version     : 5.0
# GitHub      : https://github.com/InfoSec-Research/
#
# Description :
# Configures the XFCE desktop environment to match a curated pentest
# workstation profile. Applies settings for appearance, window manager,
# wallpaper, keyboard layout, session, power management, screensaver,
# terminal emulator, and panel layout including custom launchers.
#
# NOTE: In this version, desktop customisation is a ONE-WAY operation.
# A future release will include rollback / snapshot capability.
#
# Requires: xfconf-query, xfce4-panel, xrandr, setxkbmap
###############################################################################


# ─────────────────────────────────────────────────────────────────────────────
# xfconf helper — set a single property (creates if missing)
# ─────────────────────────────────────────────────────────────────────────────

_xfset() {
    local channel="$1" property="$2" type="$3" value="$4"

    if [[ "${DRY_RUN:-false}" == true ]]; then
        msg_info "${CLR_CYAN}[DRY RUN]${CLR_RESET} xfconf-query -c ${channel} -p ${property} -s ${value} -t ${type}"
        return 0
    fi

    xfconf-query -c "$channel" -p "$property" -n -t "$type" -s "$value" 2>/dev/null || \
    xfconf-query -c "$channel" -p "$property" -s "$value" 2>/dev/null || \
        msg_warn "Failed to set ${channel}:${property}"
}


# ─────────────────────────────────────────────────────────────────────────────
# Panel launcher helper — create a .desktop file for a panel launcher
# ─────────────────────────────────────────────────────────────────────────────

_create_launcher() {
    local plugin_id="$1"
    local desktop_id="$2"
    local desktop_content="$3"
    local panel_dir="${HOME}/.config/xfce4/panel"
    local launcher_dir="${panel_dir}/launcher-${plugin_id}"

    run_cmd mkdir -p "$launcher_dir"

    if [[ "${DRY_RUN:-false}" != true ]]; then
        printf '%s\n' "$desktop_content" > "${launcher_dir}/${desktop_id}.desktop"
    fi

    _xfset xfce4-panel "/plugins/plugin-${plugin_id}" string "launcher"
}


# ─────────────────────────────────────────────────────────────────────────────
# Main entry point
# ─────────────────────────────────────────────────────────────────────────────

desktop_environment_setup() {

    # ─── Preflight checks ────────────────────────────────────────────────
    if ! command -v xfconf-query &>/dev/null; then
        msg_error "xfconf-query not found — is XFCE installed?"
        return 1
    fi

    # ─── Warning — one-way operation ─────────────────────────────────────
    msg_warn "Desktop customisation is a ${CLR_RED}one-way operation${CLR_RESET} in this version."
    msg_info "A future release will include rollback / snapshot capability."
    printf "\n"
    msg_info "The following areas will be configured:"
    printf "\n"
    printf "    • Appearance (theme, icons, fonts)\n"
    printf "    • Keyboard layout (GB / UK)\n"
    printf "    • Window manager (tiling, workspaces, compositing)\n"
    printf "    • Wallpaper and desktop behaviour\n"
    printf "    • Session and power management\n"
    printf "    • Screensaver / lock screen\n"
    printf "    • QTerminal profile\n"
    printf "    • Panel layout and custom launchers\n"
    printf "\n"

    confirm_countdown 5 "Desktop customisation will begin" || return 0


    # ─────────────────────────────────────────────────────────────────────
    #  1. APPEARANCE
    # ─────────────────────────────────────────────────────────────────────

    print_section "Appearance"

    msg_action "Setting GTK theme, icons, and fonts..."

    _xfset xsettings /Gtk/FontName             string "Hack 10"
    _xfset xsettings /Gtk/MonospaceFontName    string "Hack 10"
    _xfset xsettings /Gtk/CursorThemeName      string "Adwaita"
    _xfset xsettings /Gtk/CursorThemeSize      int    24
    _xfset xsettings /Gtk/DecorationLayout     string "icon,menu:minimize,maximize,close"
    _xfset xsettings /Gtk/ButtonImages          bool   false
    _xfset xsettings /Gtk/MenuImages            bool   false
    _xfset xsettings /Gtk/DialogsUseHeader      bool   false
    _xfset xsettings /Net/IconThemeName         string "Flat-Remix-Red-Dark"
    _xfset xsettings /Net/ThemeName             string "Kali-Dark"
    _xfset xsettings /Xfce/SyncThemes           bool   true
    _xfset xsettings /Xft/Antialias             int    1
    _xfset xsettings /Xft/DPI                   int    96
    _xfset xsettings /Xft/Hinting               int    1
    _xfset xsettings /Xft/HintStyle             string "hintslight"
    _xfset xsettings /Xft/RGBA                  string "rgb"

    msg_ok "Appearance settings applied."
    log_message "INFO" "DESKTOP: Appearance settings applied."


    # ─────────────────────────────────────────────────────────────────────
    #  2. KEYBOARD LAYOUT
    # ─────────────────────────────────────────────────────────────────────

    print_section "Keyboard Layout"

    msg_action "Setting keyboard layout to GB (UK)..."

    run_cmd setxkbmap gb

    if [[ -f /etc/default/keyboard ]]; then
        if grep -q 'XKBLAYOUT="gb"' /etc/default/keyboard; then
            msg_skip "Keyboard layout already set to GB."
        else
            msg_action "Updating /etc/default/keyboard..."
            run_cmd sudo sed -i 's/XKBLAYOUT=".*"/XKBLAYOUT="gb"/' /etc/default/keyboard
            msg_ok "Keyboard layout persisted to /etc/default/keyboard."
        fi
    else
        msg_warn "/etc/default/keyboard not found — layout set for this session only."
    fi

    msg_ok "Keyboard layout set to GB."
    log_message "INFO" "DESKTOP: Keyboard layout set to GB."


    # ─────────────────────────────────────────────────────────────────────
    #  3. WINDOW MANAGER
    # ─────────────────────────────────────────────────────────────────────

    print_section "Window Manager"

    msg_action "Configuring window manager..."

    _xfset xfwm4 /general/theme                    string "Kali-Dark"
    _xfset xfwm4 /general/title_font               string "Cantarell Bold 9"
    _xfset xfwm4 /general/title_alignment           string "center"
    _xfset xfwm4 /general/button_layout             string "O|HMC"
    _xfset xfwm4 /general/activate_action           string "bring"
    _xfset xfwm4 /general/borderless_maximize        bool   false
    _xfset xfwm4 /general/box_move                   bool   false
    _xfset xfwm4 /general/box_resize                 bool   true
    _xfset xfwm4 /general/click_to_focus             bool   true
    _xfset xfwm4 /general/cycle_preview              bool   true
    _xfset xfwm4 /general/double_click_action        string "maximize"
    _xfset xfwm4 /general/easy_click                 string "Super"
    _xfset xfwm4 /general/focus_new                  bool   true
    _xfset xfwm4 /general/frame_border_top           int    0
    _xfset xfwm4 /general/frame_opacity              int    100
    _xfset xfwm4 /general/full_width_title           bool   true
    _xfset xfwm4 /general/margin_bottom              int    20
    _xfset xfwm4 /general/margin_left                int    20
    _xfset xfwm4 /general/margin_right               int    20
    _xfset xfwm4 /general/margin_top                 int    60
    _xfset xfwm4 /general/placement_mode             string "center"
    _xfset xfwm4 /general/placement_ratio            int    20
    _xfset xfwm4 /general/raise_on_click             bool   true
    _xfset xfwm4 /general/shadow_opacity             int    50
    _xfset xfwm4 /general/shadow_delta_y             int    -3
    _xfset xfwm4 /general/show_dock_shadow           bool   true
    _xfset xfwm4 /general/show_frame_shadow          bool   true
    _xfset xfwm4 /general/snap_to_border             bool   true
    _xfset xfwm4 /general/snap_width                 int    10
    _xfset xfwm4 /general/tile_on_move               bool   true
    _xfset xfwm4 /general/use_compositing            bool   true
    _xfset xfwm4 /general/workspace_count            int    4
    _xfset xfwm4 /general/wrap_cycle                 bool   true
    _xfset xfwm4 /general/wrap_layout                bool   true
    _xfset xfwm4 /general/zoom_desktop               bool   true
    _xfset xfwm4 /general/zoom_pointer               bool   true
    _xfset xfwm4 /general/inactive_opacity            int    100
    _xfset xfwm4 /general/move_opacity                int    100
    _xfset xfwm4 /general/popup_opacity               int    100
    _xfset xfwm4 /general/resize_opacity              int    100

    msg_ok "Window manager settings applied."
    log_message "INFO" "DESKTOP: Window manager settings applied."


    # ─────────────────────────────────────────────────────────────────────
    #  4. WALLPAPER & DESKTOP
    # ─────────────────────────────────────────────────────────────────────

    print_section "Wallpaper & Desktop"

    local wallpaper_src="${RESOURCES_DIR}/wallpapers"
    local wallpaper_dest="${HOME}/Pictures"
    local wallpaper_file="${wallpaper_dest}/Wallpaper_3.jpg"

    msg_action "Deploying wallpaper files..."
    run_cmd mkdir -p "$wallpaper_dest"

    if [[ -d "$wallpaper_src" ]]; then
        for wp in "$wallpaper_src"/*.jpg; do
            [[ -f "$wp" ]] || continue
            local wp_name
            wp_name="$(basename "$wp")"
            local wp_target="${wallpaper_dest}/${wp_name}"

            if [[ -f "$wp_target" ]]; then
                msg_skip "${wp_name} already exists."
            else
                run_cmd cp "$wp" "$wp_target"
                run_cmd chmod 644 "$wp_target"
                msg_ok "Copied ${wp_name}"
            fi
        done
    else
        msg_warn "Wallpaper source directory not found: ${wallpaper_src}"
    fi

    msg_action "Setting desktop wallpaper and options..."

    _xfset xfce4-desktop /backdrop/single-workspace-mode           bool   true
    _xfset xfce4-desktop /backdrop/single-workspace-number          int    0
    _xfset xfce4-desktop /desktop-icons/style                       int    0
    _xfset xfce4-desktop /desktop-icons/icon-size                   int    48
    _xfset xfce4-desktop /desktop-menu/show                         bool   false
    _xfset xfce4-desktop /windowlist-menu/show                      bool   false

    # Detect connected monitors from xrandr and set wallpaper for each
    msg_action "Detecting connected monitors..."

    while IFS= read -r monitor_name; do
        [[ -z "$monitor_name" ]] && continue

        msg_debug "Found monitor: ${monitor_name}"

        local base="/backdrop/screen0/monitor${monitor_name}/workspace0"

        _xfset xfce4-desktop "${base}/image-show"  bool   true
        _xfset xfce4-desktop "${base}/image-style" int    5
        _xfset xfce4-desktop "${base}/last-image"  string "$wallpaper_file"

        msg_ok "Wallpaper set for ${monitor_name}"

    done < <(xrandr --query 2>/dev/null | awk '/ connected/{print $1}')

    # Fallbacks for physical hardware monitor numbering
    local i
    for i in 0 1 2 3 4; do
        _xfset xfce4-desktop "/backdrop/screen0/monitor${i}/image-show"  bool   true
        _xfset xfce4-desktop "/backdrop/screen0/monitor${i}/image-style" int    5
        _xfset xfce4-desktop "/backdrop/screen0/monitor${i}/image-path"  string "$wallpaper_file"
        _xfset xfce4-desktop "/backdrop/screen0/monitor${i}/last-image"  string "$wallpaper_file"
    done

    # Refresh desktop
    if [[ "${DRY_RUN:-false}" != true ]]; then
        xfdesktop --reload 2>/dev/null &
        sleep 1
    fi

    msg_ok "Wallpaper and desktop settings applied."
    log_message "INFO" "DESKTOP: Wallpaper and desktop settings applied."


    # ─────────────────────────────────────────────────────────────────────
    #  5. SESSION
    # ─────────────────────────────────────────────────────────────────────

    print_section "Session"

    msg_action "Configuring session settings..."

    _xfset xfce4-session /general/SessionName           string "Default"
    _xfset xfce4-session /general/LockCommand            string ""
    _xfset xfce4-session /shutdown/LockScreen             bool   true

    msg_ok "Session settings applied."
    log_message "INFO" "DESKTOP: Session settings applied."


    # ─────────────────────────────────────────────────────────────────────
    #  6. POWER MANAGER
    # ─────────────────────────────────────────────────────────────────────

    print_section "Power Manager"

    msg_action "Configuring power management..."

    _xfset xfce4-power-manager /xfce4-power-manager/dpms-on-ac-off                 int  60
    _xfset xfce4-power-manager /xfce4-power-manager/dpms-on-ac-sleep               int  45
    _xfset xfce4-power-manager /xfce4-power-manager/dpms-on-battery-off            int  30
    _xfset xfce4-power-manager /xfce4-power-manager/dpms-on-battery-sleep          int  15
    _xfset xfce4-power-manager /xfce4-power-manager/lock-screen-suspend-hibernate  bool true
    _xfset xfce4-power-manager /xfce4-power-manager/power-button-action            int  3
    _xfset xfce4-power-manager /xfce4-power-manager/show-panel-label               int  0
    _xfset xfce4-power-manager /xfce4-power-manager/show-tray-icon                 bool false

    msg_ok "Power manager settings applied."
    log_message "INFO" "DESKTOP: Power manager settings applied."


    # ─────────────────────────────────────────────────────────────────────
    #  7. SCREENSAVER / LOCK SCREEN
    # ─────────────────────────────────────────────────────────────────────

    print_section "Screensaver / Lock Screen"

    msg_action "Configuring screensaver and lock screen..."

    _xfset xfce4-screensaver /saver/idle-activation/enabled    bool   false
    _xfset xfce4-screensaver /saver/mode                       int    2
    _xfset xfce4-screensaver /lock/embedded-keyboard/enabled    bool   true
    _xfset xfce4-screensaver /lock/embedded-keyboard/command    string "onboard -e"

    # Floaters theme configuration
    _xfset xfce4-screensaver /screensavers/xfce-floaters/arguments        string "-n 11 -r"
    _xfset xfce4-screensaver /screensavers/xfce-floaters/do-rotations     bool   true
    _xfset xfce4-screensaver /screensavers/xfce-floaters/number-of-images int    11
    _xfset xfce4-screensaver /screensavers/xfce-floaters/print-stats      bool   false
    _xfset xfce4-screensaver /screensavers/xfce-floaters/show-paths       bool   false

    # Personal slideshow — uses wallpapers in ~/Pictures
    _xfset xfce4-screensaver /screensavers/xfce-personal-slideshow/arguments string "--location=${HOME}/Pictures --background-color=#000000 --no-crop"
    _xfset xfce4-screensaver /screensavers/xfce-personal-slideshow/location  string "${HOME}/Pictures"

    # Set theme list to floaters
    if [[ "${DRY_RUN:-false}" != true ]]; then
        xfconf-query -c xfce4-screensaver -p /saver/themes/list \
            -n -a -t string -s "screensavers-xfce-floaters" 2>/dev/null || true
    fi

    msg_ok "Screensaver and lock screen settings applied."
    log_message "INFO" "DESKTOP: Screensaver and lock screen settings applied."


    # ─────────────────────────────────────────────────────────────────────
    #  8. QTERMINAL
    # ─────────────────────────────────────────────────────────────────────

    print_section "QTerminal"

    local qterminal_dir="${HOME}/.config/qterminal.org"
    local qterminal_conf="${qterminal_dir}/qterminal.ini"

    msg_action "Deploying QTerminal configuration..."

    if [[ -f "$qterminal_conf" ]]; then
        msg_warn "Existing qterminal.ini found — backing up."
        run_cmd cp "$qterminal_conf" "${qterminal_conf}.bak.$(date +%Y%m%d%H%M%S)"
    fi

    run_cmd mkdir -p "$qterminal_dir"

    if [[ "${DRY_RUN:-false}" != true ]]; then
        cat > "$qterminal_conf" << 'QTERMINAL_EOF'
[General]
AskOnExit=false
AudibleBell=false
BoldIntense=true
BookmarksFile=/home/kali/.config/qterminal.org/qterminal_bookmarks.xml
BookmarksVisible=false
Borderless=false
ChangeWindowIcon=true
ChangeWindowTitle=true
CloseTabOnMiddleClick=true
ConfirmMultilinePaste=false
DisableBracketedPasteMode=false
FixedTabWidth=false
FixedTabWidthValue=500
HandleHistory=
HideTabBarWithOneTab=true
HistoryLimited=false
HistoryLimitedTo=1000
KeyboardCursorBlink=false
KeyboardCursorShape=2
LastWindowMaximized=true
MenuVisible=true
MotionAfterPaste=2
MouseAutoHideDelay=0
NoMenubarAccel=false
OpenNewTabRightToActiveTab=false
PrefDialogSize=@Size(957 700)
SavePosOnExit=true
SaveSizeOnExit=true
ScrollbarPosition=2
ShowCloseTabButton=true
SwapMouseButtons2and3=false
TabBarless=false
TabsPosition=0
Term=xterm-256color
TerminalBackgroundImage=
TerminalBackgroundMode=0
TerminalMargin=5
TerminalTransparency=0
TerminalsPreset=0
TrimPastedTrailingNewlines=true
UseBookmarks=false
UseCWD=true
UseFontBoxDrawingChars=true
WordCharacters=:@-./_~
colorScheme=Kali-Dark
emulation=solaris
enabledBidiSupport=true
focusOnMoueOver=false
fontFamily=Hack
fontSize=10
guiStyle=
highlightCurrentTerminal=true
showTerminalSizeHint=true
version=2.2.1
[DropMode]
Height=45
KeepOpen=false
ShortCut=F12
ShowOnStart=true
Width=70
[MainWindow]
ApplicationTransparency=10
fixedSize=@Size(600 400)
pos=@Point(20 60)
size=@Size(1666 1158)
state=@ByteArray(\0\0\0\xff\0\0\0\0\xfd\0\0\0\x1\0\0\0\0\0\0\0\0\0\0\0\0\xfc\x2\0\0\0\x1\xfb\0\0\0&\0\x42\0o\0o\0k\0m\0\x61\0r\0k\0s\0\x44\0o\0\x63\0k\0W\0i\0\x64\0g\0\x65\0t\0\0\0\0\0\xff\xff\xff\xff\0\0\0m\0\xff\xff\xff\0\0\x6\x82\0\0\x4o\0\0\0\x4\0\0\0\x4\0\0\0\b\0\0\0\b\xfc\0\0\0\0)
[Sessions]
size=0
[Shortcuts]
Add%20Tab=Ctrl+Shift+T
Bottom%20Subterminal=Alt+Down
Clear%20Active%20Terminal=
Close%20Tab=Ctrl+Shift+W
Collapse%20Subterminal=Ctrl+Shift+E
Copy%20Selection=Ctrl+Shift+C
Find=Ctrl+Shift+F
Fullscreen=F11
Handle%20history=
Hide%20Window%20Borders=
Left%20Subterminal=Alt+Left
Move%20Tab%20Left=Alt+Shift+Left|Ctrl+Shift+PgUp
Move%20Tab%20Right=Alt+Shift+Right|Ctrl+Shift+PgDown
New%20Window=Ctrl+Shift+N
Next%20Tab=Ctrl+PgDown
Next%20Tab%20in%20History=Ctrl+Shift+Tab
Paste%20Clipboard=Ctrl+Shift+V
Paste%20Selection=Shift+Ins
Preferences...=
Previous%20Tab=Ctrl+PgUp
Previous%20Tab%20in%20History=Ctrl+Tab
Quit=
Rename%20Session=Alt+Shift+S
Right%20Subterminal=Alt+Right
Show%20Tab%20Bar=
Split%20View%20Left-Right=Ctrl+Shift+R
Split%20View%20Top-Bottom=Ctrl+Shift+D
Tab%201=Alt+1
Tab%2010=Alt+0
Tab%202=Alt+2
Tab%203=Alt+3
Tab%204=Alt+4
Tab%205=Alt+5
Tab%206=Alt+6
Tab%207=Alt+7
Tab%208=Alt+8
Tab%209=Alt+9
Toggle%20Bookmarks=Ctrl+Shift+B
Toggle%20Menu=Ctrl+Shift+M
Top%20Subterminal=Alt+Up
Zoom%20in=Ctrl++
Zoom%20out=Ctrl+-
Zoom%20reset=Ctrl+0
QTERMINAL_EOF

        # Fix hardcoded /home/kali path to match actual user
        sed -i "s|/home/kali|${HOME}|g" "$qterminal_conf"
    fi

    msg_ok "QTerminal configuration deployed."
    log_message "INFO" "DESKTOP: QTerminal configuration deployed."


    # ─────────────────────────────────────────────────────────────────────
    #  9. PANEL
    # ─────────────────────────────────────────────────────────────────────

    print_section "Panel Configuration"

    msg_action "Configuring panel layout, plugins, and launchers..."

    # Stop panel to avoid conflicts
    msg_action "Stopping xfce4-panel..."
    xfce4-panel --quit 2>/dev/null || true
    sleep 1

    # ── Panel structure ──────────────────────────────────────────────────

    _xfset xfce4-panel /configver                            int    2
    _xfset xfce4-panel /panels/dark-mode                     bool   true
    _xfset xfce4-panel /panels/panel-1/background-style      int    0
    _xfset xfce4-panel /panels/panel-1/border-width           int    5
    _xfset xfce4-panel /panels/panel-1/enable-struts          bool   true
    _xfset xfce4-panel /panels/panel-1/enter-opacity          int    100
    _xfset xfce4-panel /panels/panel-1/leave-opacity          int    100
    _xfset xfce4-panel /panels/panel-1/length-adjust          bool   true
    _xfset xfce4-panel /panels/panel-1/mode                   int    0
    _xfset xfce4-panel /panels/panel-1/nrows                  int    1
    _xfset xfce4-panel /panels/panel-1/position               string "p=6;x=0;y=0"
    _xfset xfce4-panel /panels/panel-1/position-locked        bool   true
    _xfset xfce4-panel /panels/panel-1/size                   int    28

    if [[ "${DRY_RUN:-false}" != true ]]; then
        # Panel list — single panel
        xfconf-query -c xfce4-panel -p /panels -n -a -t int -s 1 2>/dev/null || true

        # Plugin IDs array
        xfconf-query -c xfce4-panel -p /panels/panel-1/plugin-ids -n -a \
            -t int -s 1  -t int -s 2  -t int -s 4  -t int -s 33 \
            -t int -s 30 -t int -s 31 -t int -s 32 -t int -s 10 \
            -t int -s 28 -t int -s 7  -t int -s 24 -t int -s 25 \
            -t int -s 34 -t int -s 8  -t int -s 5  -t int -s 3  \
            -t int -s 26 -t int -s 27 -t int -s 9  -t int -s 29 \
            -t int -s 11 -t int -s 12 -t int -s 14 -t int -s 16 \
            -t int -s 18 -t int -s 17 -t int -s 23 -t int -s 20 \
            -t int -s 6  -t int -s 19 -t int -s 13 -t int -s 21 \
            -t int -s 22 2>/dev/null || true

        # Panel background RGBA
        xfconf-query -c xfce4-panel -p /panels/panel-1/background-rgba -n -a \
            -t double -s 0.0 -t double -s 0.0 -t double -s 0.0 -t double -s 1.0 2>/dev/null || true

        # Length as double
        xfconf-query -c xfce4-panel -p /panels/panel-1/length -n -t double -s 100.0 2>/dev/null || true
    fi

    msg_ok "Panel structure configured."

    # ── Plugin definitions ───────────────────────────────────────────────

    msg_action "Defining panel plugins..."

    # Whiskermenu
    _xfset xfce4-panel /plugins/plugin-1                        string "whiskermenu"
    _xfset xfce4-panel /plugins/plugin-1/button-icon             string "kapman"
    _xfset xfce4-panel /plugins/plugin-1/button-single-row       bool   false
    _xfset xfce4-panel /plugins/plugin-1/show-button-icon        bool   true
    _xfset xfce4-panel /plugins/plugin-1/show-button-title       bool   false
    _xfset xfce4-panel /plugins/plugin-1/view-mode               int    1
    _xfset xfce4-panel /plugins/plugin-1/menu-width              int    750
    _xfset xfce4-panel /plugins/plugin-1/menu-height             int    700
    _xfset xfce4-panel /plugins/plugin-1/menu-opacity            int    100
    _xfset xfce4-panel /plugins/plugin-1/default-category        int    0
    _xfset xfce4-panel /plugins/plugin-1/launcher-show-description bool  false
    _xfset xfce4-panel /plugins/plugin-1/launcher-show-tooltip    bool  false
    _xfset xfce4-panel /plugins/plugin-1/recent-items-max        int    5
    _xfset xfce4-panel /plugins/plugin-1/profile-shape           int    0

    # Separators
    _xfset xfce4-panel /plugins/plugin-2        string "separator"
    _xfset xfce4-panel /plugins/plugin-2/style  int    1

    _xfset xfce4-panel /plugins/plugin-6        string "separator"
    _xfset xfce4-panel /plugins/plugin-6/style  int    0

    _xfset xfce4-panel /plugins/plugin-8        string "separator"
    _xfset xfce4-panel /plugins/plugin-8/style  int    1

    _xfset xfce4-panel /plugins/plugin-12       string "separator"
    _xfset xfce4-panel /plugins/plugin-12/expand bool  true
    _xfset xfce4-panel /plugins/plugin-12/style int    0

    _xfset xfce4-panel /plugins/plugin-13       string "separator"
    _xfset xfce4-panel /plugins/plugin-13/style int    0

    _xfset xfce4-panel /plugins/plugin-20       string "separator"
    _xfset xfce4-panel /plugins/plugin-20/style int    1

    _xfset xfce4-panel /plugins/plugin-21       string "separator"
    _xfset xfce4-panel /plugins/plugin-21/style int    1

    _xfset xfce4-panel /plugins/plugin-23       string "separator"
    _xfset xfce4-panel /plugins/plugin-23/style int    0

    _xfset xfce4-panel /plugins/plugin-27       string "separator"
    _xfset xfce4-panel /plugins/plugin-29       string "separator"

    # Show desktop
    _xfset xfce4-panel /plugins/plugin-3                    string "showdesktop"
    _xfset xfce4-panel /plugins/plugin-3/show-on-hover       bool   false

    # Directory menu
    _xfset xfce4-panel /plugins/plugin-4                    string "directorymenu"
    _xfset xfce4-panel /plugins/plugin-4/base-directory      string "$HOME"
    _xfset xfce4-panel /plugins/plugin-4/icon-name           string "system-file-manager"

    # Clipman
    _xfset xfce4-panel /plugins/plugin-5                    string "xfce4-clipman-plugin"

    # Workspace pager
    _xfset xfce4-panel /plugins/plugin-9                    string "pager"
    _xfset xfce4-panel /plugins/plugin-9/miniature-view      bool   false
    _xfset xfce4-panel /plugins/plugin-9/numbering           bool   false
    _xfset xfce4-panel /plugins/plugin-9/rows                int    1
    _xfset xfce4-panel /plugins/plugin-9/workspace-scrolling bool   true

    # Tasklist
    _xfset xfce4-panel /plugins/plugin-11                   string "tasklist"
    _xfset xfce4-panel /plugins/plugin-11/flat-buttons       bool   false
    _xfset xfce4-panel /plugins/plugin-11/grouping           bool   false
    _xfset xfce4-panel /plugins/plugin-11/show-handle        bool   false
    _xfset xfce4-panel /plugins/plugin-11/show-labels        bool   false
    _xfset xfce4-panel /plugins/plugin-11/show-tooltips      bool   true

    # Systray
    _xfset xfce4-panel /plugins/plugin-14                   string "systray"
    _xfset xfce4-panel /plugins/plugin-14/hide-new-items     bool   false
    _xfset xfce4-panel /plugins/plugin-14/icon-size          int    23
    _xfset xfce4-panel /plugins/plugin-14/single-row         bool   false
    _xfset xfce4-panel /plugins/plugin-14/square-icons       bool   true
    _xfset xfce4-panel /plugins/plugin-14/symbolic-icons     bool   false

    # PulseAudio
    _xfset xfce4-panel /plugins/plugin-16                   string "pulseaudio"
    _xfset xfce4-panel /plugins/plugin-16/enable-keyboard-shortcuts bool true

    # Notification plugin
    _xfset xfce4-panel /plugins/plugin-17                   string "notification-plugin"

    # Power manager plugin
    _xfset xfce4-panel /plugins/plugin-18                   string "power-manager-plugin"

    # Clock
    _xfset xfce4-panel /plugins/plugin-19                   string "clock"
    _xfset xfce4-panel /plugins/plugin-19/digital-layout     int    3
    _xfset xfce4-panel /plugins/plugin-19/digital-time-font  string "Hack 11"
    _xfset xfce4-panel /plugins/plugin-19/digital-time-format string "%T"
    _xfset xfce4-panel /plugins/plugin-19/mode               int    2
    _xfset xfce4-panel /plugins/plugin-19/show-week-numbers   bool   false
    _xfset xfce4-panel /plugins/plugin-19/timezone            string "Europe/London"
    _xfset xfce4-panel /plugins/plugin-19/tooltip-format      string "%A %d %B %Y"

    # Screenshot
    _xfset xfce4-panel /plugins/plugin-26                   string "screenshooter"

    # Actions menu
    _xfset xfce4-panel /plugins/plugin-22                   string "actions"
    _xfset xfce4-panel /plugins/plugin-22/appearance         int    0
    _xfset xfce4-panel /plugins/plugin-22/ask-confirmation   bool   true

    msg_ok "Plugin definitions set."

    # ── Launcher .desktop files ──────────────────────────────────────────

    msg_action "Creating launcher .desktop files..."

    # Plugin 7 — Terminal Emulator
    _create_launcher 7 "terminal-emulator" \
"[Desktop Entry]
Version=1.0
Type=Application
Exec=exo-open --launch TerminalEmulator
Icon=org.xfce.terminalemulator
StartupNotify=true
Terminal=false
Categories=Utility;X-XFCE;X-Xfce-Toplevel;
Name=Terminal Emulator
Comment=Use the command line"

    _xfset xfce4-panel /plugins/plugin-7/move-first bool true

    # Plugin 10 — Burp Suite Professional
    _create_launcher 10 "burpsuite-pro" \
'[Desktop Entry]
Type=Application
Name=Burp Suite Professional
Exec="'"${HOME}"'/BurpSuitePro/BurpSuitePro" %U
MimeType=application/x-extension-burp;
Icon='"${HOME}"'/BurpSuitePro/.install4j/BurpSuitePro.png
Categories=Application;
StartupWMClass=install4j-burp-StartBurp'

    # Plugin 24 — gedit
    _create_launcher 24 "gedit" \
"[Desktop Entry]
Name=gedit
Comment=Edit text files
Exec=gedit %U
Terminal=false
Type=Application
StartupNotify=true
MimeType=text/plain;application/x-zerosize;
Icon=rednotebook
Categories=GNOME;GTK;Utility;TextEditor;"

    _xfset xfce4-panel /plugins/plugin-24/show-label bool false

    # Plugin 25 — Root Terminal
    _create_launcher 25 "root-terminal" \
"[Desktop Entry]
Encoding=UTF-8
Exec=pkexec x-terminal-emulator
StartupNotify=false
Terminal=false
Type=Application
Name=Root Terminal Emulator
Comment=Opens a terminal as the root user, using sudo to ask for the password
Icon=utilities-root-terminal
Categories=System;Utility;TerminalEmulator;"

    # Plugin 28 — PowerShell
    _create_launcher 28 "powershell" \
'[Desktop Entry]
Comment=PowerShell command-line shell and .NET REPL
Encoding=UTF-8
Exec=/usr/share/kali-menu/exec-in-shell "pwsh"
Icon=kali-pwsh
StartupNotify=false
Terminal=true
Type=Application
Name=PowerShell
Categories=System;Utility;'

    # Plugin 30 — ONLYOFFICE
    _create_launcher 30 "onlyoffice" \
"[Desktop Entry]
Version=1.0
Name=ONLYOFFICE
GenericName=Document Editor
Comment=Edit office documents
Type=Application
Exec=/usr/bin/onlyoffice-desktopeditors %U
Terminal=false
Icon=onlyoffice-desktopeditors
Categories=Office;WordProcessor;Spreadsheet;Presentation;
StartupWMClass=ONLYOFFICE"

    # Plugin 31 — Obsidian
    _create_launcher 31 "obsidian" \
"[Desktop Entry]
Categories=GNOME;GTK;Utility;Office;
Exec=obsidian %U
Name=Obsidian
GenericName=Obsidian
Comment=Obsidian
Icon=obsidian-logo-gradient
StartupWMClass=obsidian
Terminal=false
Type=Application
MimeType=x-scheme-handler/obsidian;
Version=1.0"

    # Plugin 32 — cherrytree
    _create_launcher 32 "cherrytree" \
"[Desktop Entry]
Name=cherrytree
Comment=A hierarchical note taking application
Encoding=UTF-8
Exec=cherrytree %f
StartupNotify=false
Terminal=false
Type=Application
Categories=12-reporting;Utility;
Icon=cherrytree
MimeType=application/cherrytree-ctd;application/cherrytree-ctz;application/cherrytree-ctb;application/cherrytree-ctx;"

    # Plugin 33 — Firefox ESR
    _create_launcher 33 "firefox-esr" \
"[Desktop Entry]
Name=Firefox
Comment=Browse the World Wide Web
GenericName=Web Browser
Exec=/usr/lib/firefox-esr/firefox-esr %u
Terminal=false
Type=Application
Icon=firefox-esr
Categories=Network;WebBrowser;
StartupWMClass=firefox-esr
StartupNotify=true"

    # Plugin 34 — Settings Manager
    _create_launcher 34 "settings-manager" \
"[Desktop Entry]
Name=Settings Manager
Comment=Graphical Settings Manager for Xfce
Exec=xfce4-settings-manager
Icon=org.xfce.settings.manager
Terminal=false
Type=Application
Categories=X-XFCE;Settings;DesktopSettings;
OnlyShowIn=XFCE;"

    # Set launcher items arrays
    local panel_dir="${HOME}/.config/xfce4/panel"
    local pid

    for pid in 7 10 24 25 28 30 31 32 33 34; do
        local local_dir="${panel_dir}/launcher-${pid}"
        if [[ -d "$local_dir" ]]; then
            local desktop_file
            desktop_file="$(ls "${local_dir}/"*.desktop 2>/dev/null | head -1)"
            if [[ -n "$desktop_file" ]]; then
                local desktop_basename
                desktop_basename="$(basename "$desktop_file")"
                xfconf-query -c xfce4-panel -p "/plugins/plugin-${pid}/items" \
                    -n -a -t string -s "$desktop_basename" 2>/dev/null || true
            fi
        fi
    done

    msg_ok "All launchers created."

    # ── Restart panel ────────────────────────────────────────────────────

    msg_action "Restarting xfce4-panel..."
    if [[ "${DRY_RUN:-false}" != true ]]; then
        nohup xfce4-panel &>/dev/null &
        disown
        sleep 2
    fi

    msg_ok "Panel restarted."
    log_message "INFO" "DESKTOP: Panel configuration applied."


    # ─────────────────────────────────────────────────────────────────────
    #  DONE
    # ─────────────────────────────────────────────────────────────────────

    printf "\n"
    msg_ok "Desktop customisation complete."
    msg_info "If anything looks off, log out and back in for a full session refresh."

    log_message "NOTICE" "Desktop environment customisation completed."
}
