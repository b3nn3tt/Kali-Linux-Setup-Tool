# ─────────────────────────────────────────────────────────────────────────────
# Kali Linux Setup Tool — Makefile
# ─────────────────────────────────────────────────────────────────────────────
# Usage:
#   sudo make install        Install the tool system-wide
#   sudo make uninstall      Remove the tool (preserves user config & logs)
#   make user-config         Create user config dirs + seed default files
#   make help                Show this help
#
# Optional variables:
#   PREFIX=/usr/local        Install prefix (default)
#   DESTDIR=/tmp/pkgroot     Staging root for packaging
# ─────────────────────────────────────────────────────────────────────────────

PREFIX      ?= /usr/local
DESTDIR     ?=

BIN_DIR      = $(DESTDIR)$(PREFIX)/bin
SHARE_DIR    = $(DESTDIR)$(PREFIX)/share/kali-linux-setup-tool
FUNC_DIR     = $(SHARE_DIR)/functions
RES_DIR      = $(SHARE_DIR)/resources
TPL_DIR      = $(SHARE_DIR)/templates

SCRIPT       = kali_linux_setup_tool.sh

# ─── User-level directories (XDG compliant) ──────────────────────────────────
USER_CONFIG  = $(HOME)/.config/kali-linux-setup-tool
USER_DATA    = $(HOME)/.local/share/kali-linux-setup-tool

.PHONY: install uninstall reinstall user-config help check-root

# ─── Help ─────────────────────────────────────────────────────────────────────
help:
	@echo ""
	@echo "  Kali Linux Setup Tool — Installer"
	@echo ""
	@echo "  sudo make install       Install tool to $(PREFIX)"
	@echo "  sudo make uninstall     Remove tool (keeps user config & logs)"
	@echo "  make user-config        Create user config directories"
	@echo "  make help               Show this message"
	@echo ""
	@echo "  Custom prefix:   sudo make install PREFIX=/opt/kali-tools"
	@echo "  Package staging: make install DESTDIR=/tmp/package-root"
	@echo ""

# ─── Root check (for install/uninstall) ───────────────────────────────────────
check-root:
	@if [ "$$(id -u)" -ne 0 ]; then \
		echo "[!!] install/uninstall must be run as root (use sudo)"; \
		exit 1; \
	fi

# ─── Install ──────────────────────────────────────────────────────────────────
install: check-root
	@echo ""
	@echo "[*] Installing Kali Linux Setup Tool..."
	@echo ""

	# Create directories
	@mkdir -p $(BIN_DIR)
	@mkdir -p $(FUNC_DIR)
	@mkdir -p $(RES_DIR)
	@mkdir -p $(TPL_DIR)

	# Install main script
	@cp $(SCRIPT) $(BIN_DIR)/
	@chmod 755 $(BIN_DIR)/$(SCRIPT)
	@echo "  [+] Installed $(BIN_DIR)/$(SCRIPT)"

	# Install function library
	@cp functions/*.sh $(FUNC_DIR)/
	@chmod 644 $(FUNC_DIR)/*.sh
	@echo "  [+] Installed function library to $(FUNC_DIR)"

	# Install resources (if present)
	@if [ -d resources ] && ls resources/* 1>/dev/null 2>&1; then \
		cp -r resources/* $(RES_DIR)/; \
		echo "  [+] Installed resources to $(RES_DIR)"; \
	else \
		echo "  [--] No resources to install"; \
	fi

	# Install templates
	@if [ -d templates ] && ls templates/* 1>/dev/null 2>&1; then \
		cp -r templates/* $(TPL_DIR)/; \
		echo "  [+] Installed templates to $(TPL_DIR)"; \
	else \
		echo "  [--] No templates to install"; \
	fi

	@echo ""
	@echo "[+] Installation complete."
	@echo ""
	@echo "    Run '$(SCRIPT) --help' to get started."
	@echo "    Run 'make user-config' (as your normal user) to initialise config."
	@echo ""

# ─── Uninstall ────────────────────────────────────────────────────────────────
uninstall: check-root
	@echo ""
	@echo "[*] Uninstalling Kali Linux Setup Tool..."
	@echo ""

	@rm -f  $(BIN_DIR)/$(SCRIPT)
	@echo "  [+] Removed $(BIN_DIR)/$(SCRIPT)"

	@rm -rf $(SHARE_DIR)
	@echo "  [+] Removed $(SHARE_DIR)"

	@echo ""
	@echo "[+] Uninstall complete."
	@echo ""
	@echo "    User config and logs have been preserved:"
	@echo "      Config: ~/.config/kali-linux-setup-tool/"
	@echo "      Data:   ~/.local/share/kali-linux-setup-tool/"
	@echo ""
	@echo "    To remove these as well, run:"
	@echo "      rm -rf ~/.config/kali-linux-setup-tool ~/.local/share/kali-linux-setup-tool"
	@echo ""

# ─── Reinstall convenience ────────────────────────────────────────────────────
reinstall: uninstall install

# ─── User config scaffolding ─────────────────────────────────────────────────
# Run this as your normal user AFTER 'sudo make install'.
user-config:
	@echo ""
	@echo "[*] Setting up user configuration for $$(whoami)..."
	@echo ""

	@mkdir -p $(USER_CONFIG)/packages
	@mkdir -p $(USER_CONFIG)/repositories
	@mkdir -p $(USER_DATA)/logs
	@mkdir -p $(USER_DATA)/state

	# Seed default package list if not present
	@if [ ! -f $(USER_CONFIG)/packages/package_list.txt ]; then \
		cp $(TPL_DIR)/package_list.txt \
		   $(USER_CONFIG)/packages/package_list.txt; \
		echo "  [+] Installed default package list"; \
	else \
		echo "  [--] Package list already exists — skipping"; \
	fi

	# Seed default repository CSV
	@if [ ! -f $(USER_CONFIG)/repositories/repository_list.csv ]; then \
		cp $(TPL_DIR)/repository_list.csv \
		   $(USER_CONFIG)/repositories/repository_list.csv; \
		echo "  [+] Installed repository list"; \
	else \
		echo "  [--] Repository list already exists — skipping"; \
	fi

	@echo ""
	@echo "[+] User configuration ready."
	@echo ""
	@echo "    Config files: $(USER_CONFIG)"
	@echo "    Logs & state: $(USER_DATA)"
	@echo ""
