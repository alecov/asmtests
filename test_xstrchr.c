#include <stdio.h>
#include <stdlib.h>

extern const char* xstrchr(const char* string, char value);
extern const char* xstrchr_sse2(const char* string, char value);
extern const char* c_xstrchr(const char* string, char value);

int main(int argc, char* argv[]) {
	(void)argc;
	for (++argv; *argv; ++argv) {
		const char* result = xstrchr(*argv, '0');
		printf("%i %i\n", !!*result, result - *argv);
		result = xstrchr_sse2(*argv, '0');
		printf("%i %i\n", !!*result, result - *argv);
		result = c_xstrchr(*argv, '0');
		printf("%i %i\n", !!*result, result - *argv);
	}
	return EXIT_SUCCESS;
}
