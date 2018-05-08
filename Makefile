all: test_xatoll time_xatoll
clean:; $(RM) *.o test_xatoll time_xatoll
test_xatoll: xatoll.o c_xatoll.o
time_xatoll: xatoll.o c_xatoll.o noop.o
