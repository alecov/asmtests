#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

static long long timespec_diff(
	struct timespec clock1,
	struct timespec clock2
) {
	clock2.tv_sec -= clock1.tv_sec;
	clock2.tv_nsec -= clock1.tv_nsec;
	if (clock2.tv_nsec < 0) {
		clock2.tv_sec -= 1;
		clock2.tv_nsec += 1000000000;
	}
	return 1000*clock2.tv_sec + clock2.tv_nsec/1000000;
}

int main(void) {
	struct timespec clock1, clock2;

	puts("loop: ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__ volatile("loop .\n" :: "c"(-1));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ms\n", timespec_diff(clock1, clock2));

	puts("dec + jnz: ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__ volatile("1: decl %%ecx\njnz 1b\n" :: "c"(-1));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ms\n", timespec_diff(clock1, clock2));

	puts("test + jz + dec + jmp: ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__ volatile("1: test %%ecx, %%ecx\njz 1f\ndecl %%ecx\njmp 1b\n1:\n" :: "c"(-1));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ms\n", timespec_diff(clock1, clock2));

	puts("jcxz + dec + jmp: ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	__asm__ volatile("1: jecxz 1f\ndecl %%ecx\njmp 1b\n1:\n" :: "c"(-1));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ms\n", timespec_diff(clock1, clock2));
	return EXIT_SUCCESS;
}
