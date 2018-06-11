#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "tdiff.h"

int main(void) {
	struct timespec clock1, clock2;

	puts("loop:");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__("loopl .\n\t" :: "c"(-1));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("dec + jnz:");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__(
		"1: decl %%ecx\n\t"
		"jnz 1b\n\t"
		:: "c"(-1)
	);
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("test + jz + dec + jmp:");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__(
		"1: test %%ecx, %%ecx\n\t"
		"jz 1f\n\t"
		"decl %%ecx\n\t"
		"jmp 1b\n\t"
		"1:\n\t"
		:: "c"(-1)
	);
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("jcxz + dec + jmp:");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__(
		"1:\n\t"
		"jecxz 1f\n\t"
		"decl %%ecx\n\t"
		"jmp 1b\n\t"
		"1:\n\t"
		:: "c"(-1)
	);
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
	return EXIT_SUCCESS;
}
