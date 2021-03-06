#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include "tdiff.h"

extern const char* xstrchr(const char* string, char value);
extern const char* xstrchr_lods(const char* string, char value);
#ifdef __SSE2__
extern const char* xstrchr_sse2(const char* string, char value);
#endif
extern const char* c_xstrchr(const char* string, char value);
extern void noop();

int main(int argc, char* argv[]) {
	struct timespec clock1, clock2;
	unsigned int count;

	puts("string strchr():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strchr("1234567890", '0'));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("string strchrnul():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strchrnul("1234567890", '0'));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("string xstrchr():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		xstrchr("1234567890", '0');
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("string xstrchr_lods():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		xstrchr_lods("1234567890", '0');
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

#ifdef __SSE2__
	puts("string xstrchr_sse2():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		xstrchr_sse2("1234567890", '0');
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
#endif

	puts("string c_xstrchr():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(c_xstrchr("1234567890", '0'));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	if (argc < 2)
		return EXIT_SUCCESS;

	puts("arg strchr():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strchr(argv[1], '0'));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("arg strchrnul():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(strchrnul(argv[1], '0'));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("arg xstrchr():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		xstrchr(argv[1], '0');
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("arg xstrchr_lods():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		xstrchr_lods(argv[1], '0');
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

#ifdef __SSE2__
	puts("arg xstrchr_sse2():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		xstrchr_sse2(argv[1], '0');
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
#endif

	puts("arg c_xstrchr():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		noop(c_xstrchr(argv[1], '0'));
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
	return EXIT_SUCCESS;
}
