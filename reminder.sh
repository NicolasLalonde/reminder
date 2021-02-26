#!/bin/sh
#Copyright (C) 2021 Nicolas Lalonde

print_help() {
	printf "Usage: %s [OPTION] file\n" "$0"
	printf "Options:\n"
	printf " -h\t\tdisplay this help and exit\n"
	printf " -a\t\tadd mode: add tasks to the list\n"
	printf " -t <time>\ttimeframe for displayed tasks (i.e. \"3 weeks\")\n"
	exit 1
}

TIMEFRAME="2 weeks"
while getopts "hat:" opt
do
	case "$opt" in
		h ) print_help ;;
		a ) ADDMODE="true" ;;
		t ) TIMEFRAME=$OPTARG ;;
		? ) print_help ;;
	esac
done
shift $(expr $OPTIND - 1) #process argument after options
FILE=$1

check_package() {
	PKG="$1"
	if ! command -v "${PKG}" > /dev/null 2>&1; then
		printf "%s needs %s to run, but it is not installed.\n" "$0" "$PKG" 
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
MISSING="$MISSING$(check_package grep)"
MISSING="$MISSING$(check_package date)"
MISSING="$MISSING$(check_package sed)"
MISSING="$MISSING$(check_package awk)"

if [ ! -z "$MISSING" ] ; then #if any packages are missing, quit
	printf "%s" "$MISSING"
	exit 1
fi


add_reminder(){
	ADD=$(yad --title="Add a Task" --form --separator='|!|' --field=Category "$CATY" --field=Type "$TYPE" --field=Desc. "$DESC" --field=Date:DT "$DATE" -date-format=%y%m%d)
	if [ -z "$ADD" ]; then
		exit 0
	fi
	FIELDCOUNT=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } END {print NF }')
	if [ $FIELDCOUNT -gt 5 ]; then #yad adds a separator at the end
		yad --title="Error" --text='You cannot include the sequence: "|!|" in any of the fields.\n\nTask not added. \n\nReturning to add window, fields will be reset to last accepted value...'
		return
	fi
	CATY=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $1 }')
	TYPE=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $2 }')
	DESC=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $3 }')
	DATE=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $4 }')
	printf "FALSE|!|'%s'|!|'%s'|!|'%s'|!|%s\n" "$CATY" "$TYPE" "$DESC" "$DATE" >> $FILE
	printf "Added: '%s' '%s' '%s' %s to your tasks\n" "$CATY" "$TYPE" "$DESC" "$DATE"
}
if [ ! -z $ADDMODE ]; then
	printf "\n" >> $FILE #in case last edit did not end with newline
	while true; do
		add_reminder
	done
fi



#unfinished, use for timers
timer(){
start=$(date +%s)
printf '#!/bin/sh\n' > tmp
while true; do 
	now=$(date +%s)
	time=$(date -u --date @$(($now - $start)) +%H:%M:%S)
	. ./tmp
	printf '\f\n'
	printf '%s\n' "$time"
	sleep 1 
done | yad --text-info --justify=center --button=Start/Pause:"printf 'break\\n'" > tmp
}


MAXDATE=$(date -d "now + $TIMEFRAME" +%Y-%m-%d)
LIST=$(awk -v MAXDATE="$MAXDATE" -f preprocess.awk $FILE)
TASKS=$(printf '%s' $LIST | grep -o "FALSE'" |wc -l)

show_reminders(){
YAD='yad --list --title "Upcoming tasks" --text "'"$1"'" --no-selection --width 600 --height 600 --print-column=2 --separator="" --checklist --column "Done" --column "Line":HD --column @fore@ --column "Category" --column "Type" --column "Desc." --column "Date"'
eval "$YAD $2"
}

DONE=$(show_reminders "$TASKS tasks due in the next $TIMEFRAME" "$LIST")
#check off done items
for line in $DONE; do
	sed -i "${line}s/^FALSE/TRUE/" $FILE
done


