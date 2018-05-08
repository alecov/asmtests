.global xatoll

# const char* xatoll(const char* string, long long* value);
# A pure assembly implementation of xatoll().
xatoll:
	# Initialize registers.
	movq %rdi, %rax                # String remainder.
	xorq %rdi, %rdi                # Parse result.
	xorb %dl, %dl                  # Sign flag (1: negative).

	# Load first character.
	movzxb (%rax), %rcx

	# Test if it is a '+' character.
	cmpb $'+', %cl
	jne 1f
	incq %rax
	movzxb (%rax), %rcx
	jmp 2f

	# Test if it is a '-' character.
1:	cmpb $'-', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %rcx
	incb %dl

	# Test if the string begins with "0x".
2:	cmpb $'0', %cl
	jne .Lxatoll_dec
	leaq 1(%rax), %r8
	movb (%r8), %r11b
	orb $0x20, %r11b               # Convert 'X' to 'x'.
	cmpb $'x', %r11b
	je .Lxatoll_hex

.Lxatoll_dec:
	# A signed 64-bit number can have up to 19 decimal digits.
	# For up to 18 digits, an unrolled loop code can be repeated.
	.rept 18
1:	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoll_ret                # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg .Lxatoll_ret                #  and, if so, bail out.
	leaq (%rdi, %rdi, 4), %r11
	leaq (%rcx, %r11, 2), %rdi
	incq %rax
	movzxb (%rax), %rcx
	.endr

	# For the last digit, overflow checks are added.
	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoll_ret                # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg .Lxatoll_ret                #  and, if so, bail out.
	movq %rdi, %r10                # Use %r10 as a temporary.
	leaq (%r10, %r10, 8), %r11     # This is %r11 = 9*%r10.
	addq %r11, %r10                # Overflow if %rdx > 922337203685477580.
	jo .Lxatoll_ret
	addq %rcx, %r10                # Overflow if %rdx >= 9223372036854775800
	jo .Lxatoll_ret                #  and %cl >= 8.
	movq %r10, %rdi
	incq %rax
	jmp .Lxatoll_ret

.Lxatoll_hex:
	# Skip the "0x" part.
	addq $2, %rax
	movzxb (%rax), %rcx

	# A signed 64-bit number can have up to 16 hexadecimal digits.
	# For up to 15 digits, an unrolled loop code can be repeated.
	.rept 15
	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoll_ret                # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg 1f                          #  and, if so, jump to the 'A-F' code.
	shlq $4, %rdi
	addq %rcx, %rdi
	incq %rax
	movzxb (%rax), %rcx
	jmp 2f

1:	orb $0x20, %cl                 # Make 'A-F' into 'a-f'.
	subb $49, %cl                  # Subtract 49 ('a' - '0').
	js .Lxatoll_ret                # Bail out if the character is below 'a'.
	cmpb $5, %cl                   # Test if the character is above 'f',
	jg .Lxatoll_ret                #  and, if so, bail out.
	shlq $4, %rdi
	addb $10, %cl
	addq %rcx, %rdi
	incq %rax
	movzxb (%rax), %rcx
2:
	.endr

	# For the last digit, overflow checks are added.
	movabsq $0xF800000000000000, %r10
	subb $'0', %cl                 # Subtract '0' (0x30) from the character.
	js .Lxatoll_ret                # Bail out if the character is below '0'.
	cmpb $9, %cl                   # Test if the character is above '9',
	jg 1f                          #  and, if so, jump to the 'A-F' code.
	testq %r10, %rdi               # Overflow if %rdi > 0x7FFFFFFFFFFFFFFF.
	jnz .Lxatoll_ret
	shlq $4, %rdi
	addq %rcx, %rdi
	incq %rax
	jmp .Lxatoll_ret

1:	orb $0x20, %cl                 # Make 'A-F' into 'a-f'.
	subb $49, %cl                  # Subtract 49 ('a' - '0').
	js .Lxatoll_ret                # Bail out if the character is below 'a'.
	cmpb $5, %cl                   # Test if the character is above 'f',
	jg .Lxatoll_ret                #  and, if so, bail out.
	testq %r10, %rdi               # Overflow if %rdi > 0x7FFFFFFFFFFFFFFF.
	jnz .Lxatoll_ret
	shlq $4, %rdi
	addb $10, %cl
	addq %rcx, %rdi
	incq %rax

.Lxatoll_ret:
	testb %dl, %dl                 # Negate the result if needed.
	jz 1f
	negq %rdi
1:	movq %rdi, (%rsi)
	ret

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
