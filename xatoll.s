.global xatoll

# const char* xatoll(const char* string, long long* value);
# A pure assembly implementation of xatoll().
xatoll:
	# Initialize registers.
	movq %rdi, %rax                # String remainder.
	xorl %edi, %edi                # Parse result.
	xorl %edx, %edx                # Sign flag (1: negative).

	# Load first character.
	movzxb (%rax), %ecx

	# Test if it is a '+' character.
	cmpb $'+', %cl
	jne 1f
	incq %rax
	movzxb (%rax), %ecx
	jmp 2f

	# Test if it is a '-' character.
1:	cmpb $'-', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %ecx
	incl %edx

	# Test if the string begins with "0x".
2:	cmpb $'0', %cl
	jne .Lxatoll_dec
	incq %rax
	movzxb (%rax), %ecx
	orl $0x20, %ecx                # Convert 'X' to 'x'.
	cmpb $'x', %cl
	je .Lxatoll_hex

	# Skip an arbitrarily sized prefix of '0's.
1:	cmpb $'0', %cl
	jne 2f
	incq %rax
	movzxb (%rax), %ecx
	jmp 1b
2:

.Lxatoll_dec:
	# A signed 64-bit number can have up to 19 decimal digits.
	# For up to 18 digits, an unrolled loop code can be repeated.
	.rept 18
1:	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja .Lxatoll_dec_ret            #  '0-9' range and, if so, bail out.
	leaq (%rdi, %rdi, 4), %r11
	incq %rax
	leaq (%rcx, %r11, 2), %rdi
	movzxb (%rax), %ecx
	.endr

	# For the last digit, overflow checks are added.
	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja .Lxatoll_dec_ret            #  '0-9' range and, if so, bail out.
	movq %rdi, %r10                # Use %r10 as a temporary.
	leaq (%r10, %r10, 8), %r11     # This is %r11 = 9*%r10.
	addq %r11, %r10                # Overflow if %rdx >= 9223372036854775800
	addq %rcx, %r10                #  and %cl >= 8.
	js .Lxatoll_dec_ret
	incq %rax
	movq %r10, %rdi

.Lxatoll_dec_ret:
	testl %edx, %edx               # Negate the result if needed.
	jz 1f
	negq %rdi
1:	movq %rdi, (%rsi)
	retq

.Lxatoll_hex:
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

	# A signed 64-bit number can have up to 16 hexadecimal digits.
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
	ja .Lxatoll_hex_ret            #  'a-f' range.
	shlq $4, %rdi
	addl $10, %ecx
	incq %rax
	addq %rcx, %rdi
	movzxb (%rax), %ecx
2:
	.endr

	# For the last digit, overflow checks are added.
	movabsq $0xF800000000000000, %r10
	subl $'0', %ecx                # Subtract '0' (0x30) from the character.
	cmpb $9, %cl                   # Test if the character is outside the
	ja 1f                          #  '0-9' range.
	testq %r10, %rdi               # Overflow if %rdi > 0x07FFFFFFFFFFFFFF.
	jnz .Lxatoll_hex_ret
	shlq $4, %rdi
	incq %rax
	addq %rcx, %rdi
	jmp .Lxatoll_hex_ret

1:	orl $0x20, %ecx                # Make 'A-F' into 'a-f'.
	subl $49, %ecx                 # Subtract 49 ('a' - '0').
	cmpb $5, %cl                   # Test if the character is outside the
	ja .Lxatoll_hex_ret            #  'a-f' range.
	testq %r10, %rdi               # Overflow if %rdi > 0x07FFFFFFFFFFFFFF.
	jnz .Lxatoll_hex_ret
	shlq $4, %rdi
	addl $10, %ecx
	incq %rax
	addq %rcx, %rdi

.Lxatoll_hex_ret:
	testl %edx, %edx               # Negate the result if needed.
	jz 1f
	negq %rdi
1:	movq %rdi, (%rsi)
	retq

# Mark a non-executable stack for GNU ld.
.section .note.GNU-stack
