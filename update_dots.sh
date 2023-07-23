#!/bin/bash

# Define variables
GREEN="$(tput setaf 2)[OK]$(tput sgr0)"
RED="$(tput setaf 1)[ERROR]$(tput sgr0)"
YELLOW="$(tput setaf 3)[NOTE]$(tput sgr0)"
CAT="$(tput setaf 6)[ACTION]$(tput sgr0)"
LOG="update.log"

### Copy Config Files ###
read -n1 -rep "${CAT} Would you like to copy config files? (y,n)" CFG
if [[ $CFG =~ ^[Yy]$ ]]; then
	printf " Copying config files...\n"
	cp -r ~/.config/dunst dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/hypr dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/kitty dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/pipewire dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/rofi dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/swaylock dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/waybar dotconfig/ 2>&1 | tee -a $LOG
	cp -r ~/.config/wlogout dotconfig/ 2>&1 | tee -a $LOG
fi

### Script is done ###
printf "\n${GREEN} Dot update Completed.\n"
