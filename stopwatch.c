#include <stdlib.h>
#include <unistd.h>
#include <time.h>
#include <stdio.h>
#include <signal.h>
#include <string.h>

#define COUNTING 0
#define PAUSED 1
int state = COUNTING;
int state_change = 0;

double get_time(double seconds_precounted, time_t count_start)
{
	time_t now = time(NULL);
	double time_elapsed = difftime(now, count_start) + seconds_precounted;
	return time_elapsed;
}

void pause_stopwatch() { state = PAUSED; state_change = 1; }
void unpause_stopwatch() { state = COUNTING; state_change = 1; }

void signal_handler(int the_signal)
{
	if (the_signal == SIGUSR1){
		unpause_stopwatch();
		return;
	} else if (the_signal == SIGUSR2){
		pause_stopwatch();
		return;
	}

}

int main(int argc, char *argv[])
{
	double seconds_precounted = 0;
	time_t count_start = time(NULL);
	state = COUNTING;
	state_change = 0;

	//register signals
	struct sigaction signal_handler_struct;
	memset(&signal_handler_struct, 0, sizeof(signal_handler_struct));
	signal_handler_struct.sa_handler = signal_handler;
	signal_handler_struct.sa_flags = SA_RESTART;
	if (sigaction(SIGUSR1, &signal_handler_struct, NULL)){
		fprintf(stderr, "Couldn't register SIGUSR1 unpause handler.\n");
	}
	if (sigaction(SIGUSR2, &signal_handler_struct, NULL)){
		fprintf(stderr, "Couldn't register SIGUSR2 pause handler.\n");
	}


	if (argc > 1) {
		seconds_precounted = strtod(argv[1], NULL);
	}
	
	double time_elapsed = get_time(seconds_precounted, count_start);

	while(1){
		switch (state){
			case COUNTING:
				if (state_change == 1){
					state_change = 0;
					count_start = time(NULL);
					seconds_precounted++;//count the sleeping second
				}
				time_elapsed = get_time(seconds_precounted, count_start);
				printf("%.0f\n", time_elapsed);
				break;
			case PAUSED:
				if (state_change == 1){
					state_change = 0;
					seconds_precounted = time_elapsed;	
				}
				break;
		}
		sleep(1);
	}
}

