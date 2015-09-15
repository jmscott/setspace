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
 */
#include <string.h>
#include <errno.h>
#include <unistd.h>

#define IS_GRAPH(c) (32 < (c)&&(c) < 127)
#define IS_LOWER(c) ('a' <= (c)&&(c) <= 'z')
#define IS_DIGIT(c) ('0' <= (c)&&(c) <= '9')
#define IS_ALDIG(c) (IS_LOWER(c) || IS_DIGIT(c)) 
#define UDIGISH	    (algo_count > 1 && seen_colon && dig_count >= 32)

#define SLURP		4096

#define EXIT_MATCH	0
#define EXIT_NO_MATCH	1
#define EXIT_BAD_ARGC	2
#define EXIT_BAD_READ	3

/*
 * Synopsis:
 *  	Safe & simple string concatenator
 * Returns:
 * 	Number of non-null bytes consumed by buffer.
 *  Usage:
 *  	buf[0] = 0
 *  	_strcat(buf, sizeof buf, "hello, world");
 *  	_strcat(buf, sizeof buf, ": ");
 *  	_strcat(buf, sizeof buf, "good bye, cruel world");
 *  	write(2, buf, _strcat(buf, sizeof buf, "\n"));
 */

static int
_strcat(char *tgt, int tgtsize, char *src)
{
	char *tp = tgt;

	//  find null terminated end of target buffer
	while (*tp++)
		--tgtsize;
	--tp;

	//  copy non-null src bytes, leaving room for trailing null
	while (--tgtsize > 0 && *src)
		*tp++ = *src++;

	// target always null terminated
	*tp = 0;

	return tp - tgt;
}

static void
die(int status, char *msg)
{
	static char ERROR[] = "is-udigish: ERROR: ";
	char buf[256] = {0};

	_strcat(buf, sizeof buf, ERROR);
	_strcat(buf, sizeof buf, msg);

	write(2, buf, _strcat(buf, sizeof buf, "\n"));
	_exit(status);
}

static void
die2(int status, char *msg1, char *msg2)
{
	char msg[256] = {0};

	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, ": ");
	_strcat(msg, sizeof msg, msg2);

	die(status, msg);
}

static int
_read(char *buf, ssize_t nbytes)
{
	int nread;
again:
	nread = read(0, buf, nbytes);
	if (nread >= 0)
		return nread;
	if (errno == EINTR)
		goto again;
	die2(EXIT_BAD_READ, "read(0) failed", strerror(errno));

	//*NOTREACHED*/
	return 0;
}

int
main(int argc, char **argv)
{
	char buf[SLURP];
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

	while ((nread = _read(buf, sizeof SLURP)) > 0) {

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
