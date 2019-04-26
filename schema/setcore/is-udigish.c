/*
 *  Synopsis:
 *	Stream matches: [a-z][a-z0-9]{1,7}:[[:graph:]]{32,128}[^[:graph:]]
 *  Usage:
 *  	is-udigish <BLOB
 *  Exit Status:
 *	0	matches at least one udig in input stream.
 *	1	does not match udig in input stream.
 *	2	bad argument count on command line
 *	3	bad read(0)
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Current algorithm may be wrong.
 *
 *	Move #define NOPE() outside of function main() .
 */
#include <string.h>
#include <errno.h>

#define EXIT_MATCH	0
#define EXIT_NO_MATCH	1
#define EXIT_BAD_ARGC	2
#define EXIT_BAD_READ	3

static char progname[] = "is-udigish";
#define COMMON_NEED_READ
#include "../../common.c"

#define IS_GRAPH(c) (32 < (c)&&(c) < 127)
#define IS_LOWER(c) ('a' <= (c)&&(c) <= 'z')
#define IS_DIGIT(c) ('0' <= (c)&&(c) <= '9')
#define IS_ALDIG(c) (IS_LOWER(c) || IS_DIGIT(c)) 
#define UDIGISH	    (algo_count > 1 && seen_colon && dig_count >= 32)

int
main(int argc, char **argv)
{
	char buf[4096];
	int nread;
	int algo_count = 0, seen_colon = 0, dig_count = 0;
	char c;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

#define NOPE() {					\
	if (algo_count > 0) {				\
		algo_count = seen_colon = dig_count = 0;\
	}						\
	continue;					\
}

	while ((nread = _read(0, buf, sizeof buf)) > 0) {

		char *p, *p_end;

		p = buf;
		p_end = p + nread;

		while (p < p_end) {
			c = *p++;

			/*
			 *  All chars in udig must be ascii graphic.
			 */
			if (!IS_GRAPH(c)) {
				if (UDIGISH)
					_exit(EXIT_MATCH);
				NOPE();
			}

			/*
			 *  New udig candidate or seeing second char of algo
			 */
			if (algo_count <= 1) {
				if (algo_count == 0) {
					if (!IS_LOWER(c))
						NOPE();
				} else if (!IS_ALDIG(c))
					NOPE();
				algo_count++;
				continue;
			}

			/*
			 *  Colon not seen, but have seen algorithm candidate.
			 */
			if (seen_colon == 0) {
				algo_count++;
				if (c == ':') {
					if (--algo_count == 8)
						NOPE();
					seen_colon = 1;
					continue;
				}
				if (!IS_ALDIG(c) || algo_count > 8)
					NOPE();
				continue;
			}

			/*
			 *  Accumulating digest after seeing algo and colon.
			 */
			dig_count++;
			if (dig_count > 128)
				NOPE();
		}
	}
	_exit(UDIGISH ? EXIT_MATCH : EXIT_NO_MATCH);
}
