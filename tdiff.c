#include "tdiff.h"

long long tdiff(struct timespec clock1, struct timespec clock2) {
	clock2.tv_sec -= clock1.tv_sec;
	clock2.tv_nsec -= clock1.tv_nsec;
	if (clock2.tv_nsec < 0) {
		clock2.tv_sec -= 1;
		clock2.tv_nsec += 1000000000;
	}
	return 1000000000*clock2.tv_sec + clock2.tv_nsec;
}
