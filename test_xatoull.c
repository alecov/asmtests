#include <stdio.h>
#include <stdlib.h>

extern const char* xatoull(const char* string, unsigned long long* value);
extern const char* c_xatoull(const char* string, unsigned long long* value);

int main(int argc, char* argv[]) {
	(void)argc;
	for (++argv; *argv; ++argv) {
		unsigned long long value;
		const char* result = xatoull(*argv, &value);
		printf("%i %llu\n", !*result, value);
		result = c_xatoull(*argv, &value);
		printf("%i %llu\n", !*result, value);
	}
	return EXIT_SUCCESS;
}
