show_reminders(){
	TASKTEXT="$1"
	TASKS="$2"
	LOGO="$3"
	
	YAD='yad --list --window-icon="$LOGO" --title "Reminder - Task List" --text "'"$TASKTEXT"'" --no-selection --width 600 --height 600 --separator="#!#" --radiolist --column "Do" --column "Line":HD --column @fore@ --column "Category" --column "Type" --column "Desc." --column "Date" --column "TimeSpent":HD'
	eval "$YAD $TASKS"
}
#buttons: add tasks, edit task, start task, cancel

add_reminder(){
	FILE="$1"
	LOGO="$2"

        ADD=$(yad --window-icon="$LOGO" --title="Reminder - Add Task" --form --separator='#!#' --field=Category "$CATY" --field=Type "$TYPE" --field=Desc. "$DESC" --field=Date:DT "$DATE" --date-format=%Y-%m-%d --field='Command' "$SCMD")
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

work_on_task(){
	TASK="$1"
	TIMER_PID="$2"
	LOGO="$3"
	
	TITLE=$(printf 'Reminder - %s' "$TASK" | awk 'BEGIN {FS="#!#"} {print $3, $4, $5}')
	sed -ue 's/^/1970-01-01 +/;s/$/ seconds/' ".reminder_stopwatch_fifo" | stdbuf -oL date +%H:%M:%S -uf - | sed -ue 's/^/\f\n/' | yad --text-info --window-icon="$LOGO" --title="$TITLE" --justify=center --button=Pause:"kill -SIGUSR2 $TIMER_PID" --button=Resume:"kill -SIGUSR1 $TIMER_PID" --button=Stop:1 --button="Done Task":0

}
