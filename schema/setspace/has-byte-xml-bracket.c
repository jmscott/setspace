/*
 *  Synopsis:
 *	Byte stream matches perl pattern: /^\s*<.*[/].*>\s*$/m
 *  Usage:
 *  	has-byte-xml-bracket <BLOB;  echo $?
 *  Exit Status:
 *	0	matches
 *	1	does not match
 *	2	bad argument count on command line
 *	3	bad read(0)
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  See:
 *	For definition of prolog white space, see
 *
 *		http://www.w3.org/TR/2008/REC-xml-20081126/#sec-TextDecl
 *  Note:
 *	</> matches.
 *	A byte order mark in the prolog would NOT match.
 */
#include <string.h>
#include <errno.h>

static char progname[] = "has-byte-xml-bracket";

#define EXIT_MATCH	0
#define EXIT_NO_MATCH	1
#define EXIT_BAD_ARGC	2
#define EXIT_BAD_READ	3

#define COMMON_NEED_READ
#include "../../common.c"

#define IS_WHITE(c) ((c) == ' ' || (c) == '\n' || (c) == '\t' || (c) == '\r')

#define STATE_BEFORE_LEFT_BRACKET	0
#define STATE_BEFORE_SLASH		1
#define STATE_BEFORE_RIGHT_BRACKET	2
#define STATE_AFTER_RIGHT_BRACKET	3

int
main(int argc, char **argv)
{
	unsigned char buf[4096];
	int state = STATE_BEFORE_LEFT_BRACKET;
	int nread;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

	while ((nread = _read(0, buf, sizeof buf)) > 0) {

		unsigned char *p, *p_end;

		p = buf;
		p_end = p + nread;

		while (p < p_end) {
			unsigned char c;

			c = *p++;

			switch (state) {

			case STATE_BEFORE_LEFT_BRACKET:
				if (IS_WHITE(c))
					continue;

				//  typical case, quick case for non-xml
				if (c != '<')
					_exit(EXIT_NO_MATCH);
				state = STATE_BEFORE_SLASH;
				break;

			case STATE_BEFORE_SLASH:
				if (c == '/')
					state = STATE_BEFORE_RIGHT_BRACKET;
				break;

			case STATE_BEFORE_RIGHT_BRACKET:
				if (c == '>')
					state = STATE_AFTER_RIGHT_BRACKET;
				break;

			case STATE_AFTER_RIGHT_BRACKET:
				if (IS_WHITE(c))
					continue;
				if (c != '>')
					state = STATE_BEFORE_RIGHT_BRACKET;
				break;
			}
		}
	}
	_exit(state == STATE_AFTER_RIGHT_BRACKET ? EXIT_MATCH : EXIT_NO_MATCH);
}
