CPU_SSE2 := $(shell grep sse2 /proc/cpuinfo)
NASM := nasm
NFLAGS := -felf64

all := \
	test_xatoll \
	test_xatoull \
	test_xstrchr \
	time_xatoll \
	time_xatoull \
	time_xstrchr \
	time_strcmp \
	time_loop \
	time_mov

.PHONY: all clean
all: $(all)
clean:; $(RM) *.o $(all)

test_xatoll: xatoll.o c_xatoll.o
test_xatoull: xatoull.o c_xatoull.o
test_xstrchr: xstrchr.o xstrchr_lods.o c_xstrchr.o
time_xatoll: xatoll.o c_xatoll.o tdiff.o noop.o
time_xatoull: xatoull.o c_xatoull.o tdiff.o noop.o
time_xstrchr: xstrchr.o xstrchr_lods.o c_xstrchr.o tdiff.o noop.o
time_strcmp: strcmp.o tdiff.o
time_loop: tdiff.o
time_mov: tdiff.o

.SUFFIXES: .asm
.asm.o:; $(NASM) $(NFLAGS) $< -o$@

ifneq "$(CPU_SSE2)" ""
test_xstrchr: xstrchr_sse2.o
time_xstrchr: xstrchr_sse2.o
endif
