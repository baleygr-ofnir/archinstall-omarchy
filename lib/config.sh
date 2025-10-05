#!/bin/bash                                                                                                                                                                                                                                                             #!/bin/bash
# lib/config.sh - Interactive configuration functions

# Main configuration setup
setup_interactive_config() {
  echo "Setting up interactive configuration..."

  install_tui_tools

  get_hostname
  get_username
  get_user_password
  get_root_password
  get_timezone

  echo "Configuration entered:"
  echo "  Hostname: $HOSTNAME"
  echo "  Username: $USERNAME"
  echo "  Timezone: $TIMEZONE"
  sleep 8
}

# Hostname input with validation
get_hostname() {
  while true; do
    if command -v gum &> /dev/null; then
      HOSTNAME=$(gum input --placeholder "(e.g. archdesktop)" --prompt "Enter hostname: ")
      HOSTNAME=$(echo "$HOSTNAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    elif command -v dialog &> /dev/null; then
      HOSTNAME=$(dialog --title "System Configuration" --inputbox "Enter hostname:" 8 40 3>&1 1>&2 2>&3)
      HOSTNAME=$(echo "$HOSTNAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    else
      # shellcheck disable=SC2162
      read -p "Enter hostname: " HOSTNAME
      HOSTNAME=$(echo "$HOSTNAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      read -p "Enter hostname: " HOSTNAME
    fi

    if validate_hostname "$HOSTNAME"; then
      break
    else
      if command -v gum &> /dev/null; then
        gum style --foreground 196 "❌ Invalid hostname. Use only letters, numbers, and hyphens."
      else
        echo "Invalid hostname. Use only letters, numbers, and hyphens."
      fi
    fi
  done
}

# Username input with validation
get_username() {
  while true; do
    if command -v gum &> /dev/null; then
      USERNAME=$(gum input --placeholder "(e.g. archuser: lowercase, numbers, underscore, hyphen)" --prompt "Enter username: ")
      USERNAME=$(echo "$USERNAME" | tr -cd '[:print:]' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    elif command -v dialog &> /dev/null; then
      USERNAME=$(dialog --title "User Configuration" --inputbox "Enter username:" 8 40 3>&1 1>&2 2>&3)
      USERNAME=$(echo "$USERNAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    else
      # shellcheck disable=SC2162
      read -p "Enter username: " USERNAME
      USERNAME=$(echo "$USERNAME" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi

    if validate_username "$USERNAME"; then
      break
    else
      if command -v gum &> /dev/null; then
        gum style --foreground 196 "❌ Invalid username. Use lowercase letters, numbers, underscore, hyphen."
      else
        echo "Invalid username. Use lowercase letters, numbers, underscore, hyphen."
      fi
    fi
  done
}

# Password input with confirmation
get_user_password() {
  while true; do
    if command -v gum &> /dev/null; then
      USER_PASSWORD="$(gum input --password --placeholder "(minimum 6 characters)" --prompt "Enter user password: ")"
      USER_PASSWORD=$(echo "$USER_PASSWORD" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '%')
      # shellcheck disable=SC2155
      local confirm_password="$(gum input --password --prompt "Confirm user password: ")"
      confirm_password=$(echo "$confirm_password" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '%')
    elif command -v dialog &> /dev/null; then
      USER_PASSWORD="$(dialog --title "User Configuration" --passwordbox "Enter user password:" 8 40 3>&1 1>&2 2>&3)"
      USER_PASSWORD=$(echo "$USER_PASSWORD" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '%')
      # shellcheck disable=SC2155
      local confirm_password="$(dialog --title "User Configuration" --passwordbox "Confirm password:" 8 40 3>&1 1>&2 2>&3)"
      confirm_password=$(echo "$confirm_password" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '%')
    else
      # shellcheck disable=SC2162
      read -r -s -p "Enter user password: " USER_PASSWORD
      echo
      # shellcheck disable=SC2162
      read -r -s -p "Confirm password: " confirm_password
      echo
    fi

    if [[ $USER_PASSWORD == "$confirm_password" ]] && [[ ${#USER_PASSWORD} -ge 6 ]]; then
      break
    else
      if command -v gum &> /dev/null; then
          gum style --foreground 196 "❌ Passwords don't match or too short."
      else
          echo "Passwords don't match or too short."
      fi
    fi
  done
}

# Root password input with confirmation
get_root_password() {
  while true; do
    if command -v gum &> /dev/null; then
      ROOT_PASSWORD="$(gum input --password --placeholder "(minimum 6 characters)" --prompt "Enter secure root password: ")"
      ROOT_PASSWORD=$(echo "$ROOT_PASSWORD" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      # shellcheck disable=SC2155
      local confirm_root_password="$(gum input --password --prompt "Confirm root password: ")"
      confirm_root_password=$(echo "$confirm_root_password" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    elif command -v dialog &> /dev/null; then
      ROOT_PASSWORD="$(dialog --title "User Configuration" --passwordbox "Enter secure root password:" 8 40 3>&1 1>&2 2>&3)"
      ROOT_PASSWORD=$(echo "$ROOT_PASSWORD" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
      # shellcheck disable=SC2155
      local confirm_root_password="$(dialog --title "Root Configuration" --passwordbox "Confirm root password:" 8 40 3>&1 1>&2 2>&3)"
      confirm_root_password=$(echo "$confirm_root_password" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    else
      # shellcheck disable=SC2162
      read -s -p "Enter secure root password: " ROOT_PASSWORD
      ROOT_PASSWORD=$(echo "$ROOT_PASSWORD" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | tr -d '%')
      # shellcheck disable=SC2162
      read -s -p "Confirm root password: " confirm_root_password
      confirm_root_password=$(echo "$confirm_root_password" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    fi

    if [[ $ROOT_PASSWORD == "$confirm_root_password" ]] && [[ ${#ROOT_PASSWORD} -ge 6 ]]; then
      break
    else
      if command -v gum &> /dev/null; then
          gum style --foreground 196 "❌ Root passwords don't match or too short."
      else
          echo "Root passwords don't match or too short."
      fi
    fi
  done
}

# Timezone selection
get_timezone() {
  # Common timezone options
  local timezones=(
    "Europe/London"
    "Europe/Stockholm"
    "Europe/Berlin"
    "Europe/Paris"
    "America/New_York"
    "America/Los_Angeles"
    "America/Chicago"
    "Asia/Tokyo"
    "Asia/Shanghai"
    "Australia/Sydney"
    "Custom"
  )

  if command -v gum &> /dev/null; then
    TIMEZONE=$(printf '%s\n' "${timezones[@]}" | gum choose --header "Select timezone: ")
    # Remove any trailing whitespace
    TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
    if [[ "$TIMEZONE" == "Custom" ]]; then
      TIMEZONE=$(gum input --placeholder "(e.g. Europe/Stockholm, America/Los_Angeles, etc.)" --prompt "Enter timezone: ")
      TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
    fi
  elif command -v dialog &> /dev/null; then
    local dialog_options=()
    for i in "${!timezones[@]}"; do
      dialog_options+=("$((i+1))" "${timezones[$i]}")
    done

    # shellcheck disable=SC2155
    local selection=$(dialog --title "Timezone Selection" \
      --menu "Select timezone:" 15 50 10 \
      "${dialog_options[@]}" \
      3>&1 1>&2 2>&3)

    # shellcheck disable=SC2181
    if [[ $? -eq 0 ]]; then
      TIMEZONE="${timezones[$((selection-1))]}"
      TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
      if [[ "$TIMEZONE" == "Custom" ]]; then
          TIMEZONE=$(dialog --title "Custom Timezone" --inputbox "Enter timezone:" 8 40 3>&1 1>&2 2>&3)
          TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
      fi
    else
      TIMEZONE="Europe/Stockholm"
      TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
    fi
  else
    echo "Available timezones:"
    for i in "${!timezones[@]}"; do
      echo "$((i+1))) ${timezones[$i]}"
    done

    while true; do
      # shellcheck disable=SC2162
      read -r -p "Select timezone number (1-${#timezones[@]}): " selection
      if [[ "$selection" =~ ^[0-9]+$ ]] && [[ $selection -ge 1 ]] && [[ $selection -le ${#timezones[@]} ]]; then
        TIMEZONE="${timezones[$((selection-1))]}"
        TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
        if [[ "$TIMEZONE" == "Custom" ]]; then
          # shellcheck disable=SC2162
          read -r -p "Enter custom timezone: " TIMEZONE
          TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
        fi
        break
      else
        echo "Invalid selection. Please choose 1-${#timezones[@]}"
      fi
    done
  fi

  # Validate timezone exists
  if [[ ! -f "/usr/share/zoneinfo/${TIMEZONE}" ]]; then
    echo "Timezone $TIMEZONE not found, defaulting to Europe/Stockholm"
    TIMEZONE="Europe/Stockholm"
    TIMEZONE=$(echo "$TIMEZONE" | tr -d '\n\r' | sed 's/[[:space:]]*$//')
  fi
}
