.global xstrchr_lods

# const char* xstrchr_lods(const char* string, char value);
# A pure assembly implementation of xstrchr() using `lods`.
xstrchr_lods:
	movb %sil, %cl
	movq %rdi, %rsi

.align 16
1:	lodsb
	testb %al, %al
	jz 1f
	cmpb %al, %cl
	jnz 1b
1:	leaq -1(%rsi), %rax
	retq

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
