#include <stdio.h>
#include <stdlib.h>

#pragma GCC diagnostic ignored "-Wformat"

extern const char* xstrchr(const char* string, char value);
extern const char* xstrchr_lods(const char* string, char value);
#ifdef __SSE2__
extern const char* xstrchr_sse2(const char* string, char value);
#endif
extern const char* c_xstrchr(const char* string, char value);

int main(int argc, char* argv[]) {
	(void)argc;
	for (++argv; *argv; ++argv) {
		const char* result = xstrchr(*argv, '0');
		printf("%i %ti\n", !!*result, result - *argv);
		result = xstrchr_lods(*argv, '0');
		printf("%i %ti\n", !!*result, result - *argv);
#ifdef __SSE2__
		result = xstrchr_sse2(*argv, '0');
		printf("%i %ti\n", !!*result, result - *argv);
#endif
		result = c_xstrchr(*argv, '0');
		printf("%i %ti\n", !!*result, result - *argv);
	}
	return EXIT_SUCCESS;
}
