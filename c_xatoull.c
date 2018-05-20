/*
 * A C implementation of xatoull().
 */
const char* c_xatoull(const char* string, unsigned long long* value) {
	*value = 0;
	if (*string == '0' && (*(string + 1) | ('X' ^ 'x')) == 'x')
		for (string += 2;;) {
			signed char next = *string - '0';
			if (next < 0)
				return string;
			if (next > 9) {
				next |= 'a' ^ 'A';
				next -= 'a' - '0';
				if (next < 0)
					return string;
				if (next > 5)
					return string;
				next += 10;
			}
			if (*value & 0xF000000000000000)
				return string;
			*value <<= 4;
			*value |= next;
			++string;
		}
	for (;;) {
		signed char next = *string - '0';
#ifdef CXATOULL_OVERFLOW
		unsigned long long result;
#endif
		if (next < 0)
			return string;
		if (next > 9)
			return string;
#ifdef CXATOULL_OVERFLOW
		if (__builtin_umulll_overflow(*value, 10, &result))
			return string;
		*value = result;
		if (__builtin_uaddll_overflow(*value, next, &result))
			return string;
		*value = result;
#else
		*value = 10**value + next;
#endif
		++string;
	}
}
