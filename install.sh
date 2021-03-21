#!/bin/sh
#Copyright (C) 2021 Nicolas Lalonde


check_package() {
	PKG="$1"
	if ! command -v "${PKG}" > /dev/null 2>&1; then
		printf "Reminder needs %s to run, but it is not installed.\n" "$PKG"
		if command -v apt >/dev/null 2>&1; then #if apt is package manager
			printf "Try:\nsudo apt install %s\n" "$PKG"
		else
			printf "Install %s to run.\n" "$PKG"
		fi
	fi
}

#ensure all required packages are installed
MISSING=""
MISSING="$MISSING$(check_package yad)"
MISSING="$MISSING$(check_package date)"
MISSING="$MISSING$(check_package awk)"

if [ ! -z "$MISSING" ] ; then #if any packages are missing, quit
	printf "%s\n" "$MISSING"
	printf "Please run installer again after installing dependencies.\n"
	exit 1
fi

#download the main script
wget https://raw.githubusercontent.com/NicolasLalonde/reminder/main/reminder.sh

#download the awk preprocessing helper script
wget https://raw.githubusercontent.com/NicolasLalonde/reminder/main/preprocess.awk

#make script executable
chmod +x reminder.sh

#find config directory according to XDG specifications
CONFIG_DIR=$([ -n "$XDG_CONFIG_HOME" ] && printf '%s' "$XDG_CONFIG_HOME" || printf '%s/.config' "$HOME")

#make config directory if it doesn't exist
mkdir "$CONFIG_DIR"
mkdir "$CONFIG_DIR/reminder"

#move helper scripts into config directory
mv preprocess.awk "$CONFIG_DIR/reminder/preprocess.awk"

#move main script into user executable path
mv reminder.sh "$HOME/.local/bin/reminder"

printf "reminder has finished installing successfully.\n"


