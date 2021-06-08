show_reminders(){
	TASKTEXT="$1"
	TASKS="$2"
	YAD='yad --list --title "Upcoming tasks" --text "'"$TASKTEXT"'" --no-selection --width 600 --height 600 --separator="|!|" --radiolist --column "Do" --column "Line":HD --column @fore@ --column "Category" --column "Type" --column "Desc." --column "Date" --column "TimeSpent":HD'
	eval "$YAD $TASKS"
}
#buttons: add tasks, edit task, start task, cancel

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
