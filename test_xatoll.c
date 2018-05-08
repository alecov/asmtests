#include <stdio.h>
#include <stdlib.h>

extern const char* xatoll(const char* string, long long* value);
extern const char* c_xatoll(const char* string, long long* value);

int main(int argc, char* argv[]) {
	(void)argc;
	for (++argv; *argv; ++argv) {
		long long value;
		const char* result = xatoll(*argv, &value);
		printf("%i %lli\n", !*result, value);
		result = c_xatoll(*argv, &value);
		printf("%i %lli\n", !*result, value);
	}
	return EXIT_SUCCESS;
}
