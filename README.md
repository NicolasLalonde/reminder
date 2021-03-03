# Reminder
A simple graphical shell-based todo list manager.

Reminder is a POSIX shell script which shows you a list of your upcoming tasks within a given timeframe.
You can select a task to work on and track how much time you spend on it.
Reminder takes a file as input, so you can keep track of separate todo lists.

## Interface
Launching Reminder will display a list of your upcoming tasks. 
Overdue tasks are colored red, and tasks due today are colored orange.
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

Here is an example of what reminder looks like when using a system-wide dark theme.

![Reminder Example](https://raw.githubusercontent.com/NicolasLalonde/reminder/main/reminder.png)

Note that you can scroll down in this window, as well as sort the tasks by any of their columns by clicking the column headers.

## List Files
Reminder takes a file as its input. These files contain rows of tasks, which look something like this:

`FALSE|!|'Operating Systems'|!|'Readings'|!|'Chapter 1'|!|2021-01-28`

The first field can be `TRUE` or `FALSE`, and represents whether the task is completed.
The next three fields are the category, type, and description of the task. They must be strings enclosed in single quotes. 
The last field is the due date, in the form yyyy-mm-dd.
Note that each field is seperated by `|!|`. 

To make a new list, I suggest creating an empty file, then calling `reminder -a` on the file.
This will open an 'add task' window with which you can add new tasks to this file.
Once you have filled in the details, clicking `OK` will save the task and open a new 'add task' window with the same details prepopulated (this saves time when adding multiple similar tasks).
Once you are done adding tasks, clicking `Cancel` will exit (note that it will not add another task with the information given).

## Dependencies
Reminder uses the dialog program `yad`. `yad` does not come preinstalled on most distributions. If you use the `apt` package manager, it can be installed using `sudo apt install yad`. Reminder will tell you if you are missing any dependencies. Installing dependencies varies depending on your package manager.

## Installation
Reminder can be installed using the following commands:

`wget https://raw.githubusercontent.com/NicolasLalonde/reminder/main/reminder.sh` - This downloads the reminder shell script.

`wget https://raw.githubusercontent.com/NicolasLalonde/reminder/main/preprocess.awk` 

`chmod +x reminder.sh` - This ensures that the reminder script can be executed.

`CONFIG_DIR=$([ -n "$XDG_CONFIG_HOME" ] && printf '%s' "$XDG_CONFIG_HOME" || printf '%s/.config' "$HOME")` - Define config directory using XDG specification

`mkdir "$CONFIG_DIR"` - Make config directory if it does not exist

`mkdir "$CONFIG_DIR/reminder"` - Make reminder config directory if it does not exist

`mv preprocess.awk "$CONFIG_DIR/reminder/preprocess.awk"` - Move the awk preprocessing script into the config directory

`mv reminder.sh "$HOME/.local/bin/reminder"` - This places Reminder in your path so that you can call it with `reminder` in your shell.


You will then most likely need to install yad.

## Disclaimer
Reminder is still very much a work-in-progress. If you find any bugs, please create an issue.
