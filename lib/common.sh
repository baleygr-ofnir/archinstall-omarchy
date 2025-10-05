#!/bin/bash
# lib/common.sh - Common utilities and logging setup

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Confirmation prompt
confirm() {
  if command -v gum &> /dev/null; then
    gum confirm "$1"
  else
    { read -r -p "$(echo -e "${YELLOW}" "$1" "${NC}") [y/N]: " -n 1 -r >&3 && echo >&3; } 2>/dev/null || { read -r -p "$(echo -e "${YELLOW}" "$1" "${NC}") [y/N]: " -n 1 -r && echo; }
    [[ $REPLY =~ ^[Yy]$ ]]
  fi
}

# Install modern TUI tools if available
install_tui_tools() {
  echo "Installing TUI tools..."
  pacman -Sy --noconfirm --needed gum fzf 2>/dev/null || echo "Failed to install TUI tools, using fallbacks"
}

# Hostname validation function
validate_hostname() {
  local hostname="$1"

  # Check length (1-63 characters)
  if [[ ${#hostname} -lt 1 || ${#hostname} -gt 63 ]]; then
    return 1
  fi
  printf "Hostname: '%s'\n" "$hostname"
  # Check format: letters, numbers, hyphens (no leading/trailing hyphens)
  if [[ "$hostname" =~ ^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$ ]]; then
    return 0
  else
    return 1
  fi
}

# Username validation function
validate_username() {
  local username="$1"

  # Check length (1-32 characters)
  if [[ ${#username} -lt 1 || ${#username} -gt 32 ]]; then
    return 1
  fi

  # Check format: lowercase letters, numbers, underscore, hyphen (must start with letter)
  if [[ "$username" =~ ^[a-z][a-z0-9_-]*$ ]]; then
    return 0
  else
    return 1
  fi
}

# Timezone validation function
validate_timezone() {
  local timezone="$1"

  # Check basic format (Continent/City)
  if [[ ! "$timezone" =~ ^[A-Za-z_]+/[A-Za-z_]+$ ]]; then
    return 1
  fi

  # Check if timezone exists in system
  if command -v timedatectl &> /dev/null; then
    timedatectl list-timezones | grep -q "^$timezone$"
    return $?
  elif [[ -f "/usr/share/zoneinfo/$timezone" ]]; then
    return 0
  else
    # Fallback: check common timezones
    case "$timezone" in
      America/*|Europe/*|Asia/*|Africa/*|Australia/*|Pacific/*|Arctic/*|Atlantic/*|Indian/*)
        return 0
        ;;
      *)
        return 1
        ;;
    esac
  fi
}

# Export functions for use in sourced scripts
export -f confirm install_tui_tools validate_hostname validate_username validate_timezone
