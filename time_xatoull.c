#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "tdiff.h"

extern const char* xatoull(const char* string, unsigned long long* value);
extern const char* c_xatoull(const char* string, unsigned long long* value);
extern void noop();

int main(int argc, char* argv[]) {
	struct timespec clock1, clock2;
	unsigned int count;

	puts("string strtoull():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strtoll("1234567890", NULL, 0));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("string xatoull():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		unsigned long long value;
		xatoull("1234567890", &value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("string c_xatoull():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		unsigned long long value;
		noop(c_xatoull("1234567890", &value));
		noop(value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	if (argc < 2)
		return EXIT_SUCCESS;

	puts("arg strtoll():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strtoll(argv[1], NULL, 0));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("arg xatoull():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		unsigned long long value;
		xatoull(argv[1], &value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("arg c_xatoull():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count) {
		unsigned long long value;
		noop(c_xatoull(argv[1], &value));
		noop(value);
	}
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
	return EXIT_SUCCESS;
}
