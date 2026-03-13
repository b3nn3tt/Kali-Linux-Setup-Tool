# Kali Linux Setup Tool v4.2

A modular CLI tool to prepare Kali Linux for penetration testing. It manages system updates, APT packages, Git repositories, sudo behaviour, and desktop customisation through a structured and extensible module system.

The tool is designed to work both installed system-wide and directly from a development checkout, automatically resolving paths based on its runtime environment.

---

## Quick Start

```bash
# Clone the repository
git clone https://github.com/InfoSec-Research/kali-linux-setup-tool.git
cd kali-linux-setup-tool

# Install system-wide
sudo make install

# Create user configuration directories and seed templates
make user-config

# Verify installation
kali_linux_setup_tool.sh --help
kali_linux_setup_tool.sh --paths
```

---

## Installation

### System Install (Recommended)

```bash
sudo make install
make user-config
```

This installs:

- `/usr/local/bin/kali_linux_setup_tool.sh`
- `/usr/local/share/kali-linux-setup-tool/`

and creates user configuration directories:

- `~/.config/kali-linux-setup-tool/`
- `~/.local/share/kali-linux-setup-tool/`

### Custom Install Prefix

You may install to a custom prefix if desired:

```bash
sudo make install PREFIX=/opt/kali-tools
```

### Uninstall

```bash
sudo make uninstall
```

This removes system files but preserves user configuration and logs.

To remove user data as well:

```bash
rm -rf ~/.config/kali-linux-setup-tool
rm -rf ~/.local/share/kali-linux-setup-tool
```

---

## Development Mode

The tool can be run directly from the repository without installation.

```bash
./kali_linux_setup_tool.sh --help
```

If a `functions/` directory exists alongside the script, the tool automatically switches to development mode and resolves all paths relative to the repository.

---

## Usage

```
kali_linux_setup_tool.sh [OPTIONS] [--dry-run] [--verbose] [--quiet]
```

### Module Options

| Flag | Description |
|------|-------------|
| `-a`, `--all` | Run all modules (except log viewer) |
| `-b`, `--banner` | Display ASCII banner |
| `-d`, `--desktop` | Configure custom desktop environment |
| `-g`, `--git <action>` | Manage Git repositories (`clone`, `edit`, `delete`) |
| `-h`, `--help` | Show help message |
| `-l`, `--log` | View the session log file |
| `-p`, `--packages <action>` | Manage APT packages (`install`, `edit`) |
| `-s`, `--sudo <action>` | Manage sudo behaviour (`status`, `activate`, `disable`) |
| `-u`, `--update` | Force full system update |
| `-v`, `--version` | Display tool version |

### Global Modifiers

| Flag | Description |
|------|-------------|
| `--dry-run` | Show actions without executing them |
| `--verbose` | Enable debug-level output |
| `-q`, `--quiet` | Suppress informational output |
| `--paths` | Display resolved paths and exit |

### Usage Examples

Install packages defined in your configuration:

```bash
kali_linux_setup_tool.sh -p install
```

Preview repository cloning:

```bash
kali_linux_setup_tool.sh -g clone --dry-run
```

Clone repositories and install packages:

```bash
kali_linux_setup_tool.sh -g clone -p install
```

Check sudo configuration with debug output:

```bash
kali_linux_setup_tool.sh -s status --verbose
```

Display resolved system paths:

```bash
kali_linux_setup_tool.sh --paths
```

---

## Directory Layout

### Installed Mode

```
/usr/local/bin/kali_linux_setup_tool.sh

/usr/local/share/kali-linux-setup-tool/
├── functions/
├── resources/
└── templates/
    ├── package_list.txt
    └── repository_list.csv
```

User configuration:

```
~/.config/kali-linux-setup-tool/
├── packages/
│   └── package_list.txt
└── repositories/
    └── repository_list.csv
```

User data:

```
~/.local/share/kali-linux-setup-tool/
├── logs/
│   └── log.txt
└── state/
    └── last_system_update
```

### Development Checkout Mode

```
./kali_linux_setup_tool.sh
./functions/
./resources/
./templates/
    ├── package_list.txt
    └── repository_list.csv

./logs/log.txt
./state/last_system_update
```

---

## Architecture

The tool uses a numbered module loading system to ensure correct dependency order.

| File | Purpose |
|------|---------|
| `00_core_paths.sh` | Runtime path resolution |
| `00_core_colours.sh` | Colour constants and output helpers |
| `01_core_errors.sh` | Error handling and environment validation |
| `02_core_logging.sh` | Logging system and update tracking |
| `display_banner.sh` | ASCII banner output |
| `show_usage.sh` | Help and usage text |
| `perform_system_update.sh` | APT update and upgrade operations |
| `git_import.sh` | Git repository management |
| `package_install.sh` | APT package installation |
| `sudo_management.sh` | Sudo configuration management |
| `desktop_environment_setup.sh` | XFCE desktop customisation |

All write operations are routed through a central command wrapper to support `--dry-run` and consistent logging.

---

## Configuration

### Package List

Edit with:

```bash
kali_linux_setup_tool.sh -p edit
```

or directly:

```
~/.config/kali-linux-setup-tool/packages/package_list.txt
```

Format:

```
nmap
gobuster
bloodhound
```

Lines beginning with `#` are ignored.

### Repository List

Edit with:

```bash
kali_linux_setup_tool.sh -g edit
```

or directly:

```
~/.config/kali-linux-setup-tool/repositories/repository_list.csv
```

CSV format:

```
name,category,url,description
```

Example:

```
SecLists,Scanning,https://github.com/danielmiessler/SecLists.git,Security wordlists
```

Valid categories:

- `1.OSINT`
- `2.Scanning`
- `3.Exploitation`
- `4.Post_Exploitation`
- `5.Exploit_Development`
- `6.Custom_Tools`

---

## Author

**b3nn3tt**
b3nn3tt@hbcomputersecurity.co.uk

GitHub: [https://github.com/InfoSec-Research/](https://github.com/InfoSec-Research/)

---

## Project Goals

The Kali Linux Setup Tool aims to provide a structured, repeatable, and auditable method of preparing Kali Linux environments for penetration testing and research, while remaining modular, transparent, and easily extensible.