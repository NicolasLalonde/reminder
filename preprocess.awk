#!/bin/awk -f
BEGIN { 
	FS="#!#"; 
	ORS=" ";
	"date +%Y-%m-%d" | getline now;
}
{
	#set task colour by due date
	duedate = $5;
	if ( now == duedate )
		colour="'dark orange'";
	else if ( now > duedate)
		colour="red";
	else
		colour="'forest green'";
	#filter unwanted tasks and print
	if ( $1 == "FALSE" && $5<MAXDATE )
	{
		print $1, NR, colour, $2, $3, $4, $5, $6 
	}
}
