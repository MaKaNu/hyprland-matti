#!/bin/bash

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="install.log"

# Set the script to exit on error
set -e

printf "$(tput setaf 2) Welcome to the Arch Linux YAY Hyprland installer!\n $(tput sgr0)"

sleep 2

printf "$YELLOW PLEASE BACKUP YOUR FILES BEFORE PROCEEDING!
This script will overwrite some of your configs and files!"

sleep 2

printf "\n
$YELLOW  Some commands requires you to enter your password inorder to execute
If you are worried about entering your password, you can cancel the script now with CTRL Q or CTRL C and review contents of this script. \n"

sleep 3

# Check if yay is installed
ISparu=/sbin/paru

if [ -f "$ISparu" ]; then
	printf "\n%s - paru was located, moving on.\n" "$GREEN"
else
	printf "\n%s - paru was NOT located\n" "$YELLOW"
	read -n1 -rep "${CAT} Would you like to install paru (y,n)" INST
	if [[ $INST =~ ^[Yy]$ ]]; then
		git clone https://aur.archlinux.org/paru-bin.git
		cd paru-bin
		makepkg -si --noconfirm 2>&1 | tee -a $LOG
		cd ..
	else
		printf "%s - paru is required for this script, now exiting\n" "$RED"
		exit
	fi
	# update system before proceed
	printf "${YELLOW} System Update to avoid issue\n"
	paru -Syu --noconfirm 2>&1 | tee -a $LOG
fi

# Function to print error messages
print_error() {
	printf " %s%s\n" "$RED" "$1" "$NC" >&2
}

# Function to print success messages
print_success() {
	printf "%s%s%s\n" "$GREEN" "$1" "$NC"
}

### Install packages ####
read -n1 -rep "${CAT} Would you like to install the packages? (y/n)" inst
echo

if [[ $inst =~ ^[Nn]$ ]]; then
	printf "${YELLOW} No packages installed. Goodbye! \n"
	exit 1
fi

if [[ $inst =~ ^[Yy]$ ]]; then
	git_pkgs="grimblast-git sddm-git hyprpicker-git waybar-hyprland-git"
	hypr_pkgs="hyprland wl-clipboard wf-recorder rofi wlogout swaylock-effects dunst swaybg kitty"
	font_pkgs="ttf-nerd-fonts-symbols-common otf-firamono-nerd inter-font otf-sora ttf-fantasque-nerd noto-fonts noto-fonts-emoji ttf-comfortaa"
	font_pkgs2="ttf-jetbrains-mono-nerd ttf-icomoon-feather ttf-iosevka-nerd adobe-source-code-pro-fonts"
	dep_pkgs="checkupdates+aur python-requests"
	app_pkgs="nwg-look-bin qt5ct btop jq gvfs ffmpegthumbs swww mousepad mpv  playerctl pamixer noise-suppression-for-voice"
	app_pkgs2="polkit-gnome ffmpeg neovim viewnior pavucontrol thunar ffmpegthumbnailer tumbler thunar-archive-plugin"
	theme_pkgs="nordic-theme papirus-icon-theme starship "

	paru -R --noconfirm swaylock waybar

	if ! paru -S --noconfirm $git_pkgs $hypr_pkgs $dep_pkgs $font_pkgs $font_pkgs2 $app_pkgs $app_pkgs2 $theme_pkgs 2>&1 | tee -a $LOG; then
		print_error " Failed to install additional packages - please check the install.log \n"
		exit 1
	fi

	echo
	print_success " All necessary packages installed successfully."
else
	echo
	print_error " Packages not installed - please check the install.log"
	sleep 1
fi

### Copy Config Files ###
read -n1 -rep "${CAT} Would you like to copy config files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
	printf " Copying config files...\n"
	cp -r dotconfig/dunst ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/hypr ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/kitty ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/pipewire ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/rofi ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/swaylock ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/waybar ~/.config/ 2>&1 | tee -a $LOG
	cp -r dotconfig/wlogout ~/.config/ 2>&1 | tee -a $LOG

	# Set some files as exacutable
	chmod +x ~/.config/hypr/xdg-portal-hyprland
	chmod +x ~/.config/waybar/scripts/waybar-wttr.py
fi

### Enable SDDM Autologin ###
read -n1 -rep 'Would you like to enable SDDM autologin? (y,n)' SDDM
if [[ $SDDM == "Y" || $SDDM == "y" ]]; then
	LOC="/etc/sddm.conf"
	echo -e "The following has been added to $LOC.\n"
	echo -e "[Autologin]\nUser = $(whoami)\nSession=hyprland" | sudo tee -a $LOC
	echo -e "\n"
	echo -e "Enabling SDDM service...\n"
	sudo systemctl enable sddm
	sleep 3
fi

# BLUETOOTH
read -n1 -rep "${CAT} OPTIONAL - Would you like to install Bluetooth packages? (y/n)" BLUETOOTH
if [[ $BLUETOOTH =~ ^[Yy]$ ]]; then
	printf " Installing Bluetooth Packages...\n"
	blue_pkgs="bluez bluez-utils blueman"
	if ! yay -S --noconfirm $blue_pkgs 2>&1 | tee -a $LOG; then
		print_error "Failed to install bluetooth packages - please check the install.log"
		printf " Activating Bluetooth Services...\n"
		sudo systemctl enable --now bluetooth.service
		sleep 2
	fi
else
	printf "${YELLOW} No bluetooth packages installed..\n"
fi

### Script is done ###
printf "\n${GREEN} Installation Completed.\n"
echo -e "${GREEN} You can start Hyprland by typing Hyprland (note the capital H).\n"
read -n1 -rep "${CAT} Would you like to start Hyprland now? (y,n)" HYP
if [[ $HYP =~ ^[Yy]$ ]]; then
	if command -v Hyprland >/dev/null; then
		exec Hyprland
	else
		print_error " Hyprland not found. Please make sure Hyprland is installed by checking install.log.\n"
		exit 1
	fi
else
	exit
fi
