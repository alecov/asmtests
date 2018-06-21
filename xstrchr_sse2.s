.global xstrchr_sse2

# const char* xstrchr_sse2(const char* string, char value);
# A pure assembly implementation of xstrchr() using SSE2.
xstrchr_sse2:
	# Broadcast `value` to every byte in %xmm4, and clear %xmm5.
	movd %esi, %xmm4
	punpcklbw %xmm4, %xmm4
	punpcklwd %xmm4, %xmm4
	pshufd $0, %xmm4, %xmm4
	pxor %xmm5, %xmm5

	# If SSSE3 is available, instead of the above, use:
	#movd %esi, %xmm4
	#pxor %xmm5, %xmm5
	#pshufb %xmm5, %xmm4

	# Test for paragraph alignment.
	testb $0x0F, %dil
	jz .Lxstrchr_loop2

	# Unaligned pointer; do the first iteration using an unaligned load.

	# Process the first (unaligned) 16 bytes.
	movdqu (%rdi), %xmm0
	movdqa %xmm0, %xmm1
	pcmpeqb %xmm4, %xmm0
	pcmpeqb %xmm5, %xmm1
	por %xmm1, %xmm0
	pmovmskb %xmm0, %eax
	testl %eax, %eax
	jz 1f

	bsfl %eax, %eax
	addq %rdi, %rax
	retq

	# If nothing was found, skip 16 bytes, realign the pointer and continue.
1:	addq $0x10, %rdi
	andb $0xF0, %dil
	jmp .Lxstrchr_loop2

.align 16
.Lxstrchr_loop1:
	addq $0x40, %rdi

.Lxstrchr_loop2:
	# This optimized loop processes 64 bytes per iteration. %xmm0 to %xmm3
	# hold together 64 consecutive bytes. A `pxor` against %xmm4 clears
	# bytes containing `value`, and a `pminub` against the original vector
	# (which should be loaded quickly since it's been cached) clears null
	# bytes. The result is a null byte for either `value` or null bytes in
	# the original vector. The ordering of some instructions has been
	# interleaved in order to provide better scheduling.

1:	movdqa 0x00(%rdi), %xmm0

	pxor %xmm4, %xmm0
	movdqa 0x10(%rdi), %xmm1
	pminub 0x00(%rdi), %xmm0

	pxor %xmm4, %xmm1
	movdqa 0x20(%rdi), %xmm2
	pminub 0x10(%rdi), %xmm1

	pxor %xmm4, %xmm2
	movdqa 0x30(%rdi), %xmm3
	pminub 0x20(%rdi), %xmm2

	pxor %xmm4, %xmm3
	pminub 0x30(%rdi), %xmm3

	pminub %xmm1, %xmm0
	pminub %xmm2, %xmm0
	pminub %xmm3, %xmm0
	pcmpeqb %xmm5, %xmm0
	pmovmskb %xmm0, %eax
	testl %eax, %eax
	jz .Lxstrchr_loop1

	# At this point, something (either `value` or the terminating null byte)
	# was found; reload %xmm0 (which has been clobbered by the loop above)
	# and do the necessary tests to determine what has been found before.
	movdqa (%rdi), %xmm0
	pxor %xmm4, %xmm0
	pminub (%rdi), %xmm0

	pcmpeqb %xmm5, %xmm0
	pmovmskb %xmm0, %r9d
	pcmpeqb %xmm5, %xmm1
	pmovmskb %xmm1, %r8d
	pcmpeqb %xmm5, %xmm2
	pmovmskb %xmm2, %edx
	pcmpeqb %xmm5, %xmm3
	pmovmskb %xmm3, %eax

	# Calculate the offset (0-63) and return the pointer.
	shll $0x10, %eax
	orq %rdx, %rax
	shlq $0x10, %rax
	orq %r8, %rax
	shlq $0x10, %rax
	orq %r9, %rax

	bsfq %rax, %rax
	addq %rdi, %rax
	retq

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
