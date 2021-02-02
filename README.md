# Reminder
A simple graphical shell-based todo list manager.

Reminder is a POSIX shell script which shows you a list of your upcoming tasks within a given timeframe.
To use it, simply download and call the reminder.sh script on your todo list file (i.e. `./reminder.sh file`), the other files in the repository are not needed to run.
Reminder takes a file as input, so you can keep track of separate todo lists.

## Interface
Launching Reminder will display a list of your upcoming tasks. 
Overdue tasks are colored red.
You can check off tasks from the list: the next time you open this list, those tasks won't be listed (although they won't be removed from the file).
Clicking `OK` will save which tasks you checked off, clicking `Cancel` will act as if you didn't check off any tasks.


By default, Reminder will show you the tasks due in the next 2 weeks.
This can be changed by using the `-t` flag, which takes as an argument a string with the desired time frame.
This time frame indicates how much time into the future you want to see, any tasks with a due date past this date will not be shown.
This string is passed as an argument to the `date` program, and so takes any string that the `date` program takes.
Here are a few examples:

`reminder -t "2 weeks" file` - show tasks due in at most 2 weeks

`reminder -t "2 days" file` - show tasks due in at most 2 days

`reminder -t "2 months" file` - show tasks due in at most 2 months

`reminder -t "2 days ago" file` - show tasks due at most 2 days ago

`reminder -t "2 months 3 days" file` - show tasks due in at most 2 months and 3 days

## List Files
Reminder takes a file as its input. These files contain rows of tasks, which look something like this:

`FALSE 'Operating Systems' 'Readings' 'Chapter 1' 2021-01-28`

The first field can be `TRUE` or `FALSE`, and represents whether the task is completed.
The next three fields are the category, type, and description of the task. They must be strings enclosed in single quotes. 
The last field is the due date, in the form yyyy-mm-dd. 

To make a new list, I suggest creating an empty file, then calling `reminder -a` on the file.
This will open an 'add task' window with which you can add new tasks to this file.
Once you have filled in the details, clicking `OK` will save the task and open a new 'add task' window with the same details prepopulated (this saves time when adding multiple similar tasks).
Once you are done adding tasks, clicking `Cancel` will exit (note that it will not add another task with the information given).

## Dependencies
Reminder uses the dialog program `yad`. `yad` does not come preinstalled on most distributions. If you use the `apt` package manager, it can be installed using `sudo apt install yad`.

## Disclaimer
Reminder is still very much a work-in-progress. If you find any bugs, please create an issue.
