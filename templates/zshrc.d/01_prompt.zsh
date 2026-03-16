#!/usr/bin/env zsh
###############################################################################
# Kali Linux Setup Tool — Prompt Customisation
# Managed snippet: ~/.zshrc.d/01_prompt.zsh
#
# Multi-line pentest prompt with dynamic IP detection.
# Shows eth0, tun0 (VPN), and wlan0 addresses when available.
###############################################################################

# ─── IP detection ─────────────────────────────────────────────────────────────
# These run once at shell startup. To refresh mid-session, run: exec zsh

_kali_prompt_ip() {
    local iface="$1"
    ip -4 addr show "$iface" 2>/dev/null \
        | grep -v 127.0.0.1 \
        | grep -v secondary \
        | grep -Po 'inet \K[\d.]+' \
        | head -1
}

# ─── Build prompt ─────────────────────────────────────────────────────────────

_kali_build_prompt() {
    local ip_eth0 ip_tun0 ip_wlan0
    local seg_local="" seg_vpn="" seg_wifi=""

    # Root gets red prompt chrome, normal user gets green
    local chrome name_seg
    if [[ "$EUID" -eq 0 ]]; then
        chrome='red'
        name_seg='ROOT'
    else
        chrome='green'
        name_seg='PENTEST USER'
    fi

    ip_eth0=$(_kali_prompt_ip eth0)
    ip_tun0=$(_kali_prompt_ip tun0)
    ip_wlan0=$(_kali_prompt_ip wlan0)

    [[ -n "$ip_eth0"  ]] && seg_local="%F{${chrome}}─(🖥️ %F{cyan}${ip_eth0}%b%F{${chrome}})"
    [[ -n "$ip_tun0"  ]] && seg_vpn="%F{${chrome}}─(🔒%F{yellow}${ip_tun0}%b%F{${chrome}})"
    [[ -n "$ip_wlan0" ]] && seg_wifi="%F{${chrome}}─(📶%F{red}${ip_wlan0}%F{${chrome}})"

    local dir_seg="%B%F{yellow}%(6~.%-1~/…/%4~.%5~)%F{${chrome}}"

    local line1="%F{${chrome}}┌──(%F{magenta}${name_seg}%F{${chrome}})${seg_local}${seg_vpn}${seg_wifi}"
    local line2=$'\n'"├──(${dir_seg})"
    local line3=$'\n'"└─%F{magenta}➤ "

    PROMPT="${line1}${line2}${line3}"
    RPROMPT="%F{${chrome}}[%F{reset}%t%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)%F{${chrome}} ]"
}

_kali_build_prompt
unfunction _kali_prompt_ip _kali_build_prompt

# ─── New-line spacing ─────────────────────────────────────────────────────────
# Print a blank line before each prompt (except the very first one).

_kali_newline_before_prompt=yes
precmd() {
    if [[ "$_kali_newline_before_prompt" == yes ]]; then
        if [[ -z "$_KALI_FIRST_PROMPT_DONE" ]]; then
            _KALI_FIRST_PROMPT_DONE=1
        else
            print ""
        fi
    fi
}
