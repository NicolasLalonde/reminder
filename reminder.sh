#!/bin/sh
#Copyright (C) 2021 Nicolas Lalonde

PREPROCESS_SCRIPT=$([ -e "$XDG_CONFIG_HOME\/reminder\/preprocess.awk" ] && printf '%s/reminder/preprocess.awk' "$XDG_CONFIG_HOME" || printf '%s/.config/reminder/preprocess.awk' "$HOME")

TIMER_SCRIPT=$([ -e "$XDG_CONFIG_HOME\/reminder\/stopwatch.o" ] && printf '%s/reminder/stopwatch.o' "$XDG_CONFIG_HOME" || printf '%s/.config/reminder/stopwatch.o' "$HOME")

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


#in gui
add_reminder(){
	ADD=$(yad --title="Add a Task" --form --separator='#!#' --field=Category "$CATY" --field=Type "$TYPE" --field=Desc. "$DESC" --field=Date:DT "$DATE" --date-format=%Y-%m-%d --field='Command' "$SCMD")
	if [ -z "$ADD" ]; then
		exit 0
	fi
	FIELDCOUNT=$(printf "%s" "$ADD" | awk 'BEGIN {FS="#!#" } END {print NF }')
	if [ $FIELDCOUNT -gt 6 ]; then #yad adds a separator at the end
		yad --title="Error" --text='You cannot include the sequence: "#!#" in any of the fields.\n\nTask not added. \n\nReturning to add window, fields will be reset to last accepted value...'
		return
	fi
	CATY=$(printf "%s" "$ADD" | awk 'BEGIN {FS="#!#" } {print $1 }')
	TYPE=$(printf "%s" "$ADD" | awk 'BEGIN {FS="#!#" } {print $2 }')
	DESC=$(printf "%s" "$ADD" | awk 'BEGIN {FS="#!#" } {print $3 }')
	DATE=$(printf "%s" "$ADD" | awk 'BEGIN {FS="#!#" } {print $4 }')
	SCMD=$(printf "%s" "$ADD" | awk 'BEGIN {FS="#!#" } {print $5 }')
	#try again if date not valid
	date -d "$DATE" || (yad --title="Error" --text='Please enter a valid date...';return)
	
	printf "FALSE#!#'%s'#!#'%s'#!#'%s'#!#%s#!#0#!#%s#!#\n" "$CATY" "$TYPE" "$DESC" "$DATE" "$SCMD" >> $FILE
	printf "Added: '%s' '%s' '%s' %s %s to your tasks\n" "$CATY" "$TYPE" "$DESC" "$DATE" "$SCMD"
}
#not in gui
if [ ! -z $ADDMODE ]; then
	printf "\n" >> $FILE #in case last edit did not end with newline
	while true; do
		add_reminder
	done
fi

#in gui
show_reminders(){
YAD='yad --list --title "Upcoming tasks" --text "'"$1"'" --no-selection --width 600 --height 600 --separator="#!#" --radiolist --column "Do" --column "Line":HD --column @fore@ --column "Category" --column "Type" --column "Desc." --column "Date" --column "TimeSpent":HD'
eval "$YAD $2"
}



MAXDATE=$(date -d "now + $TIMEFRAME" +%Y-%m-%d)

while true; do
LIST=$(awk -v MAXDATE="$MAXDATE" -f "$PREPROCESS_SCRIPT" "$FILE")
TASKS=$(printf '%s' "$LIST" | grep -o "FALSE [0-9]" |wc -l)
TASK=$(show_reminders "$TASKS tasks due in the next $TIMEFRAME" "$LIST")
if [ $? -ne 0 ] || [ -z "$TASK" ] ; then
	exit
fi


TITLE=$(printf '%s' "$TASK" | awk 'BEGIN {FS="#!#"} {print $3, $5}')
LINENUM=$(printf '%s' "$TASK" | awk 'BEGIN {FS="#!#"} {print $2}')
SCMD=$(awk -v line=$LINENUM 'BEGIN {FS="#!#"} {if (NR == line) print $7}' $FILE)
[ -z "$SCMD" ] || eval "$SCMD" &
TOTALTIME=$(printf '%s' "$TASK" | awk 'BEGIN {FS="#!#"} {print $7}')
[ -p ".reminder_stopwatch_fifo" ] && rm ".reminder_stopwatch_fifo"
[ -p ".reminder_stopwatch_fifo" ] || mkfifo ".reminder_stopwatch_fifo" 
$TIMER_SCRIPT "$TOTALTIME" > ".reminder_stopwatch_fifo" &
TIMER_PID=$!  

sed -ue 's/^/1970-01-01 +/;s/$/ seconds/' ".reminder_stopwatch_fifo" | stdbuf -oL date +%H:%M:%S -uf - | sed -ue 's/^/\f\n/' | yad --text-info --title="$TITLE" --justify=center --button=Pause:"kill -SIGUSR2 $TIMER_PID" --button=Resume:"kill -SIGUSR1 $TIMER_PID" --button=Stop:1 --button="Done Task":0

#change how to get time, kill stopwatch
EXITCODE=$?
TASKDONE="FALSE"
if [ $EXITCODE -eq 0 ]; then
	TASKDONE="TRUE"
fi
TOTALTIME=$(head -n 1 .reminder_stopwatch_fifo)
kill $TIMER_PID
rm .reminder_stopwatch_fifo


#I don't like how this reprints every line just to change a single one
FILE2=$(awk -v LINENUM=$LINENUM -v TASKDONE=$TASKDONE -v TOTALTIME=$TOTALTIME 'BEGIN {FS="#!#"; OFS="#!#"} { if ( NR == LINENUM ) {$1 = TASKDONE; $6 = TOTALTIME;} print $0 }' $FILE)
printf '%s' "$FILE2" > $FILE

done
