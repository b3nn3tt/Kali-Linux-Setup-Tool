#!/usr/bin/env zsh
###############################################################################
# Kali Linux Setup Tool — Custom Aliases
# Managed snippet: ~/.zshrc.d/02_aliases.zsh
#
# Pentest-oriented shortcuts and quality-of-life aliases.
# Edit freely — the setup tool will ask before overwriting.
###############################################################################

# ─── Quick servers ────────────────────────────────────────────────────────────
alias pyserve='python3 -m http.server 80'
alias smbserver='python3 /usr/share/doc/python3-impacket/examples/smbserver.py -smb2support TEST .'

# ─── History management ──────────────────────────────────────────────────────
alias nuke='exec rm "$HISTFILE"'
alias clear_history='rm -f ~/.zsh_history && kill -9 $$'

# ─── Listing helpers ─────────────────────────────────────────────────────────
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'
