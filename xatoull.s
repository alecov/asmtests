.global xatoull

# const char* xatoull(const char* string, unsigned long long* value);
# A pure assembly implementation of xatoull().
xatoull:
	# Initialize registers.
	movq %rdi, %rax                # String remainder.
	xorl %edi, %edi                # Parse result.

	# Load first character.
	movzxb (%rax), %ecx

	# Test if the string begins with "0x".
2:	cmpb $'0', %cl
	jne .Lxatoull_dec
	incq %rax
	movzxb (%rax), %ecx
	orl $0x20, %ecx                # Convert 'X' to 'x'.
	cmpb $'x', %cl
	je .Lxatoull_hex

	# Skip an arbitrarily sized prefix of '0's.
1:	cmpb $'0', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %ecx
	jmp 1b
2:

.Lxatoull_dec:
	# An unsigned 64-bit number can have up to 20 decimal digits.
	# For up to 19 digits, an unrolled loop code can be repeated.
	.rept 19
1:	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja .Lxatoull_dec_ret           #  '0-9' range and, if so, bail out.
	leaq (%rdi, %rdi, 4), %r11
	incq %rax
	leaq (%rcx, %r11, 2), %rdi
	movzxb (%rax), %ecx
	.endr

	# For the last digit, overflow checks are added.
	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja .Lxatoull_dec_ret           #  '0-9' range and, if so, bail out.
	movq %rdi, %r10                # Use %r10 as a temporary.
	leaq (%r10, %r10, 8), %r11     # This is %r11 = 9*%r10.
	addq %r11, %r10                # Overflow if %rdx >=18446744073709551610
	addq %rcx, %r10                #  and %cl >= 6.
	js .Lxatoull_dec_ret
	incq %rax
	movq %r10, (%rsi)
	retq

.Lxatoull_dec_ret:
	movq %rdi, (%rsi)
	retq

.Lxatoull_hex:
	# Skip the "0x" part.
	incq %rax
	movzxb (%rax), %ecx

	# Skip an arbitrarily sized prefix of '0's.
1:	cmpb $'0', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %ecx
	jmp 1b
2:

	# An unsigned 64-bit number can have up to 16 hexadecimal digits.
	# For up to 15 digits, an unrolled loop code can be repeated.
	.rept 15
	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja 1f                          #  '0-9' range.
	shlq $4, %rdi
	incq %rax
	addq %rcx, %rdi
	movzxb (%rax), %ecx
	jmp 2f

1:	orl $0x20, %ecx                # Make 'A-F' into 'a-f'.
	subl $49, %ecx                 # Subtract 49 ('a' - '0').
	cmpb $5, %cl                   # Test if the character is outside the
	ja .Lxatoull_hex_ret           #  'a-f' range.
	shlq $4, %rdi
	addl $10, %ecx
	incq %rax
	addq %rcx, %rdi
	movzxb (%rax), %ecx
2:
	.endr

	# For the last digit, overflow checks are added.
	movabsq $0xF000000000000000, %r10
	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja 1f                          #  '0-9' range.
	testq %r10, %rdi               # Overflow if %rdi > 0x0FFFFFFFFFFFFFFF.
	jnz .Lxatoull_hex_ret
	shlq $4, %rdi
	incq %rax
	addq %rcx, %rdi
	jmp .Lxatoull_hex_ret

1:	orl $0x20, %ecx                # Make 'A-F' into 'a-f'.
	subl $49, %ecx                 # Subtract 49 ('a' - '0').
	cmpb $5, %cl                   # Test if the character is outside the
	ja .Lxatoull_hex_ret           #  'a-f' range.
	testq %r10, %rdi               # Overflow if %rdi > 0x0FFFFFFFFFFFFFFF.
	jnz .Lxatoull_hex_ret
	shlq $4, %rdi
	addl $10, %ecx
	incq %rax
	addq %rcx, %rdi

.Lxatoull_hex_ret:
	movq %rdi, (%rsi)
	retq

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
