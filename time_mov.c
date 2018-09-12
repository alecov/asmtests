#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "tdiff.h"

void time_movb() {
	__asm__(
		".rept 1000\n\t"
		"movb $'0', %%cl\n\t"
		/*"xorl %%ecx, %%ecx\n\t"*/
		"addl %%ecx, %%eax\n\t"
		".endr\n\t"
		:::"cl", "rax"
	);
}

void time_movl() {
	__asm__(
		".rept 1000\n\t"
		"movl $'0', %%ecx\n\t"
		/*"xorl %%ecx, %%ecx\n\t"*/
		"addl %%ecx, %%eax\n\t"
		".endr\n\t"
		:::"ecx", "eax"
	);
}

int main(void) {
	struct timespec clock1, clock2;
	unsigned int count;

	puts("time_movb:");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 1000000; ++count)
		time_movb();
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("time_movl:");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 1000000; ++count)
		time_movl();
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
	return EXIT_SUCCESS;
}
