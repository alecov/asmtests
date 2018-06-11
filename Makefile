all = \
	test_xatoll \
	test_xatoull \
	test_xstrchr \
	time_xatoll \
	time_xatoull \
	time_xstrchr \
	time_loop
all: $(all)
clean:; $(RM) *.o $(all)
test_xatoll: xatoll.o c_xatoll.o
test_xatoull: xatoull.o c_xatoull.o
test_xstrchr: xstrchr.o xstrchr_sse2.o c_xstrchr.o
time_xatoll: xatoll.o c_xatoll.o tdiff.o noop.o
time_xatoull: xatoull.o c_xatoull.o tdiff.o noop.o
time_xstrchr: xstrchr.o xstrchr_sse2.o c_xstrchr.o tdiff.o noop.o
time_loop: tdiff.o
