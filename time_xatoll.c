#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>

extern const char* xatoll(const char* string, long long* value);
extern const char* c_xatoll(const char* string, long long* value);
extern void noop();

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
	return 1000000000*clock2.tv_sec + clock2.tv_nsec;
}

int main(int argc, char* argv[]) {
	struct timespec clock1, clock2;
	unsigned int count;

	(void)argc;

	puts("string atoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(atoll("1234567890"));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	puts("string strtoull(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strtoll("1234567890", NULL, 0));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	puts("string xatoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		long long value;
		xatoll("1234567890", &value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	puts("string c_xatoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		long long value;
		noop(c_xatoll("1234567890", &value));
		noop(value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	if (argc < 2)
		return EXIT_SUCCESS;

	puts("arg atoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(atoll(argv[1]));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	puts("arg strtoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strtoll(argv[1], NULL, 0));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	puts("arg xatoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		long long value;
		xatoll(argv[1], &value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));

	puts("arg c_xatoll(): ");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		long long value;
		noop(c_xatoll(argv[1], &value));
		noop(value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("\t%lli ns\n", timespec_diff(clock1, clock2));
	return EXIT_SUCCESS;
}
