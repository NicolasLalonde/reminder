#!/bin/sh
#Copyright (C) 2021 Nicolas Lalonde

PREPROCESS_SCRIPT=$([ -e "$XDG_CONFIG_HOME\/reminder\/preprocess.awk" ] && printf '%s/reminder/preprocess.awk' "$XDG_CONFIG_HOME" || printf '%s/.config/reminder/preprocess.awk' "$HOME")

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
	ADD=$(yad --title="Add a Task" --form --separator='|!|' --field=Category "$CATY" --field=Type "$TYPE" --field=Desc. "$DESC" --field=Date:DT "$DATE" --date-format=%Y-%m-%d --field='Command' "$SCMD")
	if [ -z "$ADD" ]; then
		exit 0
	fi
	FIELDCOUNT=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } END {print NF }')
	if [ $FIELDCOUNT -gt 6 ]; then #yad adds a separator at the end
		yad --title="Error" --text='You cannot include the sequence: "|!|" in any of the fields.\n\nTask not added. \n\nReturning to add window, fields will be reset to last accepted value...'
		return
	fi
	CATY=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $1 }')
	TYPE=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $2 }')
	DESC=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $3 }')
	DATE=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $4 }')
	SCMD=$(printf "%s" "$ADD" | awk 'BEGIN {FS="\|\!\|" } {print $5 }')
	
	#try again if date not valid
	date -d "$DATE" || (yad --title="Error" --text='Please enter a valid date...';return)
	
	printf "FALSE|!|'%s'|!|'%s'|!|'%s'|!|%s|!|0|!|%s|!|\n" "$CATY" "$TYPE" "$DESC" "$DATE" "$SCMD" >> $FILE
	printf "Added: '%s' '%s' '%s' %s %s to your tasks\n" "$CATY" "$TYPE" "$DESC" "$DATE" "$SCMD"
}
if [ ! -z $ADDMODE ]; then
	printf "\n" >> $FILE #in case last edit did not end with newline
	while true; do
		add_reminder
	done
fi

show_reminders(){
YAD='yad --list --title "Upcoming tasks" --text "'"$1"'" --no-selection --width 600 --height 600 --separator="|!|" --radiolist --column "Do" --column "Line":HD --column @fore@ --column "Category" --column "Type" --column "Desc." --column "Date" --column "TimeSpent":HD'
eval "$YAD $2"
}



MAXDATE=$(date -d "now + $TIMEFRAME" +%Y-%m-%d)

while true; do
LIST=$(awk -v MAXDATE="$MAXDATE" -f "$PREPROCESS_SCRIPT" "$FILE")
TASKS=$(printf '%s' "$LIST" | grep -o "FALSE [0-9]" |wc -l)
TASK=$(show_reminders "$TASKS tasks due in the next $TIMEFRAME" "$LIST")
if [ $? -ne 0 ]; then
	exit
fi
TITLE=$(printf '%s' "$TASK" | awk 'BEGIN {FS="\|\!\|"} {print $3, $5}')
LINENUM=$(printf '%s' "$TASK" | awk 'BEGIN {FS="\|\!\|"} {print $2}')
SCMD=$(awk -v line=$LINENUM 'BEGIN {FS="\|\!\|"} {if (NR == line) print $7}' $FILE)
[ -z "$SCMD" ] || eval "$SCMD" &
TOTALTIME=$(printf '%s' "$TASK" | awk 'BEGIN {FS="\|\!\|"} {print $7}')
ADDTIME=0
printf 'start' > .reminder_state.var
while true; do 	
	STATE=$(cat ./.reminder_state.var)
	case "$STATE" in
		*start ) #does not overide the file so we need a wildcard
			if [ $ADDTIME -eq 0 ]; then #make sure we are paused
				START=$(date +%s)
			fi
			printf 'count' > .reminder_state.var
			;;
		count )
			NOW=$(date +%s)
			ADDTIME=$(date -u -d @$(($NOW - $START)) +%s)
			FULLTOTAL=$(($ADDTIME + $TOTALTIME))
			SHOWNTIME=$(date -u -d @$FULLTOTAL +%H:%M:%S)
			printf '%s' "$FULLTOTAL" > .reminder_time.var
			printf '\f\n' 
			printf '%s\n' "$SHOWNTIME"
			;;
		*pause )
			TOTALTIME=$(($ADDTIME + $TOTALTIME))
			ADDTIME=0
			printf 'wait' > .reminder_state.var
			;;
		wait ) 
			printf '\f\n'
			printf '%s\n (paused)\n' "$SHOWNTIME"
			;;
	esac
	sleep 1 
done | yad --text-info --title="$TITLE" --justify=center --button=Pause:"printf 'pause'" --button=Resume:"printf 'start'" --button=Stop:1 --button="Done Task":0 >> .reminder_state.var #yad output is a stream so file can't be overridden anyways

EXITCODE=$?
TASKDONE="FALSE"
if [ $EXITCODE -eq 0 ]; then
	TASKDONE="TRUE"
fi
TOTALTIME=$(cat .reminder_time.var)
rm .reminder_state.var
rm .reminder_time.var

#I don't like how this reprints every line just to change a single one
FILE2=$(awk -v LINENUM=$LINENUM -v TASKDONE=$TASKDONE -v TOTALTIME=$TOTALTIME 'BEGIN {FS="\|\!\|"; OFS="|!|"} { if ( NR == LINENUM ) {$1 = TASKDONE; $6 = TOTALTIME;} print $0 }' $FILE)
printf '%s' "$FILE2" > $FILE

done
