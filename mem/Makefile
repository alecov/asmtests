all: mem
mem: mem.c mem.ld
run: mem
	truncate -s1M data
	setarch x86_64 -R ./mem | hd
clean:; rm -f mem data
