/*
 * A C implementation of xstrchr().
 */
const char* c_xstrchr(const char* string, char value) {
	while (*string && *string != value)
		++string;
	return string;
}
