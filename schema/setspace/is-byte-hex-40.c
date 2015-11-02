/*
 *  Synopsis:
 *	Stream contains 40 contiguous ascii hex bytes: 0123456789abcdef
 *  Usage:
 *  	byte-hex-40 <BLOB
 *  Exit Status:
 *	0	matches 40 contiguous ascii hex digits in stream
 *	1	does not match 40 contiguous ascii hex digits in stream
 *	2	bad argument count on command line
 *	3	bad read(0)
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Current algorithm may be wrong.
 */
#include <string.h>
#include <errno.h>

static char progname[] = "is-byte-hex-40";

#define EXIT_MATCH	0
#define EXIT_NO_MATCH	1
#define EXIT_BAD_ARGC	2
#define EXIT_BAD_READ	3

#define COMMON_NEED_READ
#include "../../common.c"

#define IS_HEX(c) (('0' <= c&&c <= '9') || ('a' <= (c)&&(c) <= 'f'))

int
main(int argc, char **argv)
{
	unsigned char buf[4096];
	int nread;
	int hex_count = 0;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

	while ((nread = _read(0, buf, sizeof buf)) > 0) {

		unsigned char *p, *p_end;

		p = buf;
		p_end = p + nread;

		while (p < p_end) {
			char c = *p++;

			if (IS_HEX(c)) {
				if (++hex_count == 40)
					_exit(EXIT_MATCH);
			} else
				hex_count = 0;
		}
	}
	_exit(EXIT_NO_MATCH);
}
