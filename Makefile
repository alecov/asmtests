all=test_xatoll time_xatoll test_xatoull time_xatoull time_loop
all: $(all)
clean:; $(RM) *.o $(all)
test_xatoll: xatoll.o c_xatoll.o
test_xatoull: xatoull.o c_xatoull.o
time_xatoll: xatoll.o c_xatoll.o tdiff.o noop.o
time_xatoull: xatoull.o c_xatoull.o tdiff.o noop.o
time_loop: tdiff.o
