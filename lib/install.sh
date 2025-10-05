#!/bin/bash
# lib/install.sh - Base system configuration


configure_system() {
	set -e
	# Set timezone
	echo "Setting timezone..."
	ln -sf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime
	hwclock --systohc

	# Prereqs for arch-chroot env
	echo "Enabling extra and multilib repositories and installing packages..."
	sed -i \
	-e '/^#\?\[extra\]/s/^#//' \
	-e '/^\[extra\]/,+1{/^#\?Include.*mirrorlist/s/^#//}' \
	-e '/^#\?\[multilib\]/s/^#//' \
	-e '/^\[multilib\]/,+1{/^#\?Include.*mirrorlist/s/^#//}' /etc/pacman.conf
	pacman -Syu --noconfirm --needed \
		firewalld \
		chromium \
		docker \
		docker-compose \
		neovim \
		nerd-fonts \
		nodejs-lts-jod \
		networkmanager \
		nmap \
		git \
		tmux \
		zsh \
		zsh-autocomplete \
		zsh-autosuggestions \
		zsh-completions \
		zsh-doc \
		zsh-history-substring-search \
		zsh-syntax-highlighting

	# User configuration
	echo "Creating user ${USERNAME}..."
	useradd -m -G docker,storage,wheel -s /bin/zsh "${USERNAME}"
	echo '${USERNAME}:${USER_PASSWORD}' | chpasswd -c SHA512

	# Root configuration
	echo 'root:${ROOT_PASSWORD}' | chpasswd -c SHA512

	# Sudo config
	sed -i -e '/^#\? %wheel.*) ALL.*/s/^# //' /etc/sudoers
	sleep 2

	# Paru install
	echo "----Installing paru - rust-based Arch User Repository helper (User password required)----"
	sleep 2
	git clone https://aur.archlinux.org/paru.git /tmp/paru
	chown -R ${USERNAME} /tmp/paru
	cd /tmp/paru
	sudo -u ${USERNAME} makepkg -si --noconfirm
	cd
	sleep 2

	# yay install
	echo "----Installing yay - Arch User Repository helper (User password required)----"
	sleep 2
	git clone https://aur.archlinux.org/yay.git /tmp/yay
	chown -R ${USERNAME} /tmp/yay
	cd /tmp/yay
	sudo -u ${USERNAME} makepkg -si --noconfirm
	cd
	sleep 2
	# Set locale
	echo "Setting locale... (User password required)"
	mv /etc/locale.gen /etc/locale.gen.bak
	sudo -u ${USERNAME} paru -S --noconfirm en_se

	# Enable NetworkManager
	systemctl enable NetworkManager
	systemctl enable firewalld

	# Enable package cache cleanup
	echo "Enabling automatic package cache cleanup..."
	systemctl enable paccache.timer


	echo "Installing Omarchy... (User password required)"
	git clone https://github.com/malik-na/omarchy-mac.git /tmp/omarchy-mac	
	mv /tmp/omarchy-mac /tmp/omarchy
	chown -R ${USERNAME}:${USERNAME} /tmp/omarchy
	cd /tmp/omarchy
	sudo -u ${USERNAME} bash install.sh
	
	# Cleanup
	echo "Cleaning up package cache... (User password required)"
	rm -rf /tmp/omarchy
	sudo -u ${USERNAME} paru -Scc --noconfirm
}
