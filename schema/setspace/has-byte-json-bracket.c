/*
 *  Synopsis:
 *	Byte stream matches perl pattern: /^\s*\[.*?\]/m or /^\s*{.*?}/m
 *  Usage:
 *  	has-byte-json-bracket.c <BLOB; echo $?
 *  Exit Status:
 *	0	matches
 *	1	does not match
 *	2	bad argument count on command line
 *	3	bad read(0)
 *	4	unknown error
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
#include <string.h>
#include <errno.h>

static char progname[] = "has-byte-json-bracket";

#define EXIT_MATCH	0
#define EXIT_NO_MATCH	1
#define EXIT_BAD_ARGC	2
#define EXIT_BAD_READ	3

#define COMMON_NEED_READ
#include "../../common.c"

#define IS_WHITE(c) ((c) == ' ' || (c) == '\n' || (c) == '\t' || (c) == '\r')
#define IS_OPEN(c) ((c) == '[' || (c) == '{')

#define ST_BEFORE_OPEN	0
#define ST_BEFORE_CLOSE	1

int
main(int argc, char **argv)
{
	unsigned char buf[4096];
	int state = ST_BEFORE_OPEN;
	int nread;
	unsigned char c, c_close = 0;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

	while ((nread = _read(0, buf, sizeof buf)) > 0) {

		unsigned char *p, *p_end;

		p = buf;
		p_end = p + nread;

		while (p < p_end) {
			c = *p++;

			switch (state) {
			case ST_BEFORE_OPEN:
				if (IS_WHITE(c))
					continue;

				//  typical case, quick case for non-json
				if (!IS_OPEN(c))
					_exit(EXIT_NO_MATCH);
				if (c == '[')
					c_close = ']';
				else
					c_close = '}';
				state = ST_BEFORE_CLOSE;
				break;
			case ST_BEFORE_CLOSE:
				if (c == c_close)
					_exit(EXIT_MATCH);
				break;
			}
		}
	}
	_exit(EXIT_NO_MATCH);
}
