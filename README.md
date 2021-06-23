# Reminder
A simple graphical shell-based todo list manager.

Reminder is a POSIX shell script which shows you a list of your upcoming tasks within a given timeframe.
You can select a task to work on and track how much time you spend on it.
Reminder takes a file as input, so you can keep track of separate todo lists.

## Contents
1. [Interface](https://github.com/NicolasLalonde/reminder#interface)
2. [Task List Files](https://github.com/NicolasLalonde/reminder#task_list_files)
3. [Dependencies](https://github.com/NicolasLalonde/reminder#dependencies)
4. [Installation](https://github.com/NicolasLalonde/reminder#installation)
5. [Disclaimer](https://github.com/NicolasLalonde/reminder#disclaimer)

## Interface
### The Task List Window
Running Reminder on a file will open the following window:

![Reminder Dark](https://raw.githubusercontent.com/NicolasLalonde/reminder/main/images/reminder_tasklist.png)

(Using a dark theme)

![Reminder Light](https://raw.githubusercontent.com/NicolasLalonde/reminder/main/images/reminder_tasklist_light.png)

(Using a light theme)


Note that you can scroll down in this window, as well as sort the tasks by any of their columns by clicking the column headers.


By default, Reminder will show you the tasks due in the next 2 weeks.
This can be changed by using the `-t` flag, which takes as an argument a string with the desired time frame.
This time frame indicates how much time into the future you want to see, any tasks with a due date past this date will not be shown.
This string is passed as an argument to the `date` program, and so takes any string that the `date` program takes.
Here are a few examples:

`reminder -t "2 weeks" <filename>` - show tasks due in at most 2 weeks

`reminder -t "2 days" <filename>` - show tasks due in at most 2 days

`reminder -t "2 months" <filename>` - show tasks due in at most 2 months

`reminder -t "2 days ago" <filename>` - show tasks due at most 2 days ago

`reminder -t "2 months 3 days" <filename>` - show tasks due in at most 2 months and 3 days



Overdue tasks are colored red, and tasks due today are colored orange.

### The Stopwatch Window
You can select a task and click the `OK` button to start working on it.

![Reminder Timer](https://raw.githubusercontent.com/NicolasLalonde/reminder/main/images/reminder_timer.png)

This will execute the start command for the task, if any (See List Files section) and open a stopwatch window which keeps track of how long the task has been worked on.

The `Pause` button temporarilly pauses the timer.

The `Resume` button resumes a paused timer.

The `Stop` button stops the timer, saves the current time, and returns to the task list.

The `Done Task` button marks the current task as completed.

If a task which has already been started and stopped is started again, the timer will resume from the last time saved.
Note that the timer window only goes up to 24 hours.
Past that, the seconds are still counted accurately in the underlying file, but the timer will show itself looping back to 0.
As such, I reccomend splitting up longer tasks into manageable chunks.


## Task List Files
Reminder takes a file as its input. These files contain rows of tasks, which look something like this:

`FALSE#!#'Operating Systems'#!#'Readings'#!#'Chapter 1'#!#2021-01-28#!#342#!#evince ~/pdf/operating_systems:three_easy_pieces.pdf -p 1#!#`

The first field can be `TRUE` or `FALSE`, and represents whether the task is completed.
The next three fields are the category, type, and description of the task. They must be strings enclosed in single quotes. 
The fifth field is the due date, in the form yyyy-mm-dd.
The sixth field is the number of seconds already spent working on the task.
The last field is the command to be executed when starting the task.
All fields are optional.
Note that each field is seperated by `#!#`. 
Each record is seperated by a newline, and the final record must also be followed by one.



### The Add Task Window
To make a new list, I suggest creating an empty file, then calling `reminder -a <filename>` on the file.
This will open an 'add task' window with which you can add new tasks to this file.

![Reminder Add](https://raw.githubusercontent.com/NicolasLalonde/reminder/main/images/reminder_addtask.png)

This window can also be used to add tasks to an existing list.
Once you have filled in the details, clicking `OK` will save the task and open a new 'add task' window with the same details prepopulated (this saves time when adding multiple similar tasks).
Once you are done adding tasks, clicking `Cancel` will exit (note that it will not add another task with the information given).

## Dependencies
Reminder uses the dialog program `yad`. `yad` does not come preinstalled on most distributions. If you use the `apt` package manager, it can be installed using `sudo apt install yad`. Reminder will tell you if you are missing any dependencies. Installing dependencies varies depending on your package manager.

## Installation
Reminder can be installed using the following command:

`curl https://raw.githubusercontent.com/NicolasLalonde/reminder/main/install.sh | sh`

This will run the `install.sh` file found in the repository. 
It will alert you of any missing dependencies. 
If there are any, it will quit.
You will then most likely need to install yad.
In this case you will need to install the missing dependencies and rerun the installer.


## Disclaimer
Reminder is still very much a work-in-progress. If you find any bugs, please create an issue.

The entire reminder project (i.e. this repository) is licensed under the GNU GPL version 3 license. A copy of the license is included in the repository.
