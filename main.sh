#!/bin/bash
# main.sh - Arch Linux Modular Btrfs Installation Script
# Main orchestrator that sources modular components

set -e

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Global variables
HOSTNAME=""
USERNAME=""
USER_PASSWORD=""
ROOT_PASSWORD=""
TIMEZONE=""

# Source all modules
source "${SCRIPT_DIR}/lib/common.sh"
source "${SCRIPT_DIR}/lib/config.sh"
source "${SCRIPT_DIR}/lib/install.sh"

# Main installation flow
main() {
  check_requirements
  setup_interactive_config
  confirm_installation
  perform_installation
}

check_requirements() {
  if [[ $EUID -ne 0 ]]; then
      echo "This script must be run as root"
  fi

  echo "Updating system clock..."
  timedatectl set-ntp true
}

confirm_installation() {
  echo "Installation Summary:"
  echo "  Hostname: $HOSTNAME"
  echo "  Username: $USERNAME"

  echo "This will DESTROY ALL DATA on $DISK"
  confirm "Continue with installation?"
}

perform_installation() {
  configure_system
}

# Run main function
main "$@"
