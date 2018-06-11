.global xstrchr

# const char* xstrchr(const char* string, char value);
# A pure assembly implementation of xstrchr().
xstrchr:
	movq %rdi, %rax
	jmp 1f

.align 16
2:	incq %rax
1:	movb (%rax), %cl
	testb %cl, %cl
	jz 1f
	cmpb %cl, %sil
	jnz 2b
1:	retq

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
