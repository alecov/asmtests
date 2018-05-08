/*
 * A C implementation of xatoll().
 */
const char* c_xatoll(const char* string, long long* value) {
	int sign = 0;
	if (*string == '+')
		++string;
	else if (*string == '-') {
		sign = 1;
		++string;
	}
	*value = 0;
	if (*string == '0' && (*(string + 1) | ('X' ^ 'x')) == 'x')
		for (string += 2;;) {
			signed char next = *string - '0';
			if (next < 0)
				goto end;
			if (next > 9) {
				next |= 'a' ^ 'A';
				next -= 'a' - '0';
				if (next < 0)
					goto end;
				if (next > 5)
					goto end;
				next += 10;
			}
			if (*value & 0xF800000000000000)
				goto end;
			*value <<= 4;
			*value |= next;
			++string;
		}
	for (;;) {
		signed char next = *string - '0';
#ifdef CXATOLL_OVERFLOW
		long long result;
#endif
		if (next < 0)
			goto end;
		if (next > 9)
			goto end;
#ifdef CXATOLL_OVERFLOW
		if (__builtin_smulll_overflow(*value, 10, &result))
			goto end;
		*value = result;
		if (__builtin_saddll_overflow(*value, next, &result))
			goto end;
		*value = result;
#else
		*value = 10**value + next;
#endif
		++string;
	}
end:
	if (sign)
		*value = -*value;
	return string;
}
