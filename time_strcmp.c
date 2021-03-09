#define _GNU_SOURCE
#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <time.h>
#include "tdiff.h"

extern int strcmp_cmps(const char* s1, const char* s2);
extern int strcmp_lods(const char* s1, const char* s2);

int main(int argc, char* argv[]) {
	struct timespec clock1, clock2;
	unsigned int count;

	assert(strcmp_cmps("abc", "abc") == 0);
	assert(strcmp_cmps("abc", "ab") > 0);
	assert(strcmp_cmps("ab", "abc") < 0);
	assert(strcmp_cmps("abd", "abc") > 0);
	assert(strcmp_cmps("abc", "abd") < 0);
	assert(strcmp_lods("abc", "abc") == 0);
	assert(strcmp_lods("abc", "ab") > 0);
	assert(strcmp_lods("ab", "abc") < 0);
	assert(strcmp_lods("abd", "abc") > 0);
	assert(strcmp_lods("abc", "abd") < 0);

	puts("strcmp_cmps():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		strcmp_cmps("1234567890", "1234567890");
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("strcmp_lods():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		strcmp_lods("1234567890", "1234567890");
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	if (argc < 3)
		return EXIT_SUCCESS;


	puts("arg strcmp_cmps():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		strcmp_cmps(argv[1], argv[2]);
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);

	puts("arg strcmp_lods():");
	clock_gettime(CLOCK_MONOTONIC, &clock1);
	for (count = 0; count < 10000000; ++count)
		strcmp_lods(argv[1], argv[2]);
	clock_gettime(CLOCK_MONOTONIC, &clock2);
	printf("%8lli ms\n", tdiff(clock1, clock2)/1000000);
	return EXIT_SUCCESS;
}
