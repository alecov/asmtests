#define _GNU_SOURCE
#include <assert.h>
#include <err.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/mman.h>
#include <unistd.h>

char array[1024*1024];

int main(void) {
	assert(((intptr_t)array & (getpagesize() - 1)) == 0);
	fprintf(stderr, "array = %p\n", array);
	int file = open("data", O_RDWR);
	if (file < 0)
		err(1, "open()");
	void* ptr = mmap(array, sizeof array, PROT_READ | PROT_WRITE,
		MAP_FIXED | MAP_SHARED | MAP_POPULATE, file, 0);
	if (ptr == MAP_FAILED)
		err(1, "mmap()");
	if (write(1, array, sizeof array) < 0)
		err(1, "write()");
}
