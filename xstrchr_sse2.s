.global xstrchr_sse2

# const char* xstrchr_sse2(const char* string, char value);
# A pure assembly implementation of xstrchr() using SSE2.
xstrchr_sse2:
	# Initialize registers.
	movq %rdi, %rax                # Return value.

	# Broadcast `value` to every byte in %xmm2, and clear %xmm3.
	movd %esi, %xmm2
	punpcklbw %xmm2, %xmm2
	punpcklwd %xmm2, %xmm2
	pshufd $0, %xmm2, %xmm2
	pxor %xmm3, %xmm3

	# If SSSE3 is available, instead of the above, use:
	#movd %esi, %xmm2
	#pxor %xmm3, %xmm3
	#pshufb %xmm3, %xmm2

	# Test for paragraph alignment.
	testb $0x0F, %al
	jz .Lxstrchr_loop

	# Unaligned pointer; do the first iteration using an unaligned load.

	# Load 16 bytes in both %xmm0 and %xmm1.
	movdqu (%rax), %xmm0
	movdqa %xmm0, %xmm1

	# Scan for both `value` (%xmm2) and the null byte (%xmm3) in %xmm0/1.
	pcmpeqb %xmm2, %xmm0
	pcmpeqb %xmm3, %xmm1
	por %xmm1, %xmm0               # Merge the results.
	pmovmskb %xmm0, %ecx           # Produce a 'presence map' mask in %ecx.
	bsfl %ecx, %ecx                # Scan for the first '1' bit in %ecx.
	jnz .Lxstrchr_ret

	# If nothing was found, skip 16 bytes, realign the pointer and continue.
	addq $0x10, %rax
	andb $0xF0, %al
	jmp .Lxstrchr_loop

.align 16
.Lxstrchr_loop:
	# Load 16 bytes in both %xmm0 and %xmm1.
	movdqa (%rax), %xmm0
	movdqa %xmm0, %xmm1

	# Scan for both `value` (%xmm2) and the null byte (%xmm3) in %xmm0/1.
	pcmpeqb %xmm2, %xmm0
	pcmpeqb %xmm3, %xmm1
	por %xmm1, %xmm0               # Merge the results.
	pmovmskb %xmm0, %ecx           # Produce a 'presence map' mask in %ecx.
	bsfl %ecx, %ecx                # Scan for the first '1' bit in %ecx.
	jnz .Lxstrchr_ret

	# If nothing was found, skip 16 bytes and continue.
	addq $0x10, %rax
	jmp .Lxstrchr_loop

.Lxstrchr_ret:
	addq %rcx, %rax
	retq

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
