all: test_xatoll
clean:; $(RM) *.o test_xatoll
test_xatoll: xatoll.o c_xatoll.o
