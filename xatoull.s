.global xatoull

# const char* xatoull(const char* string, unsigned long long* value);
# A pure assembly implementation of xatoull().
xatoull:
	# Initialize registers.
	movq %rdi, %rax                # String remainder.
	xorq %rdi, %rdi                # Parse result.

	# Load first character.
	movzxb (%rax), %rcx

	# Test if the string begins with "0x".
2:	cmpb $'0', %cl
	jne .Lxatoull_dec
	incq %rax
	movzxb (%rax), %rcx
	orb $0x20, %cl                 # Convert 'X' to 'x'.
	cmpb $'x', %cl
	je .Lxatoull_hex

	# Skip an arbitrary sized prefix of '0's.
1:	cmpb $'0', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %rcx
	jmp 1b
2:

.Lxatoull_dec:
	# An unsigned 64-bit number can have up to 20 decimal digits.
	# For up to 19 digits, an unrolled loop code can be repeated.
	.rept 19
1:	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoull_dec_ret           # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg .Lxatoull_dec_ret           #  and, if so, bail out.
	leaq (%rdi, %rdi, 4), %r11
	leaq (%rcx, %r11, 2), %rdi
	incq %rax
	movzxb (%rax), %rcx
	.endr

	# For the last digit, overflow checks are added.
	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoull_dec_ret           # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg .Lxatoull_dec_ret           #  and, if so, bail out.
	movq %rdi, %r10                # Use %r10 as a temporary.
	leaq (%r10, %r10, 8), %r11     # This is %r11 = 9*%r10.
	addq %r11, %r10                # Overflow if %rdx >=18446744073709551610
	addq %rcx, %r10                #  and %cl >= 6.
	js .Lxatoull_dec_ret
	movq %r10, %rdi
	incq %rax
	jmp .Lxatoull_dec_ret

.Lxatoull_dec_ret:
	movq %rdi, (%rsi)
	ret

.Lxatoull_hex:
	# Skip the "0x" part.
	addq $2, %rax
	movzxb (%rax), %rcx

	# Skip an arbitrary sized prefix of '0's.
1:	cmpb $'0', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %rcx
	jmp 1b
2:

	# An unsigned 64-bit number can have up to 16 hexadecimal digits.
	# For up to 15 digits, an unrolled loop code can be repeated.
	.rept 15
	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoull_hex_ret           # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg 1f                          #  and, if so, jump to the 'A-F' code.
	shlq $4, %rdi
	addq %rcx, %rdi
	incq %rax
	movzxb (%rax), %rcx
	jmp 2f

1:	orb $0x20, %cl                 # Make 'A-F' into 'a-f'.
	subb $49, %cl                  # Subtract 49 ('a' - '0').
	js .Lxatoull_hex_ret           # Bail out if the character is below 'a'.
	cmpb $5, %cl                   # Test if the character is above 'f',
	jg .Lxatoull_hex_ret           #  and, if so, bail out.
	shlq $4, %rdi
	addb $10, %cl
	addq %rcx, %rdi
	incq %rax
	movzxb (%rax), %rcx
2:
	.endr

	# For the last digit, overflow checks are added.
	movabsq $0xF000000000000000, %r10
	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoull_hex_ret           # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg 1f                          #  and, if so, jump to the 'A-F' code.
	testq %r10, %rdi               # Overflow if %rdi > 0x0FFFFFFFFFFFFFFF.
	jnz .Lxatoull_hex_ret
	shlq $4, %rdi
	addq %rcx, %rdi
	incq %rax
	jmp .Lxatoull_hex_ret

1:	orb $0x20, %cl                 # Make 'A-F' into 'a-f'.
	subb $49, %cl                  # Subtract 49 ('a' - '0').
	js .Lxatoull_hex_ret           # Bail out if the character is below 'a'.
	cmpb $5, %cl                   # Test if the character is above 'f',
	jg .Lxatoull_hex_ret           #  and, if so, bail out.
	testq %r10, %rdi               # Overflow if %rdi > 0x0FFFFFFFFFFFFFFF.
	jnz .Lxatoull_hex_ret
	shlq $4, %rdi
	addb $10, %cl
	addq %rcx, %rdi
	incq %rax

.Lxatoull_hex_ret:
	movq %rdi, (%rsi)
	ret

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
