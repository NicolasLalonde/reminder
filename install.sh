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


