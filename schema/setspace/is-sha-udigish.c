/*
 *  Synopsis:
 *	Stream matches: [a-z][a-z0-9]{1,7}:[[:graph:]]{32,128}[^[:graph:]]
 *  Usage:
 *  	is-sha-udigish <BLOB
 *  Exit Status:
 *	0	matches at least one sha: udig in input stream.
 *	1	does not match sha udig in input stream.
 *	2	bad argument count on command line
 *	3	bad read(0)
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
#include <string.h>
#include <errno.h>
#include <unistd.h>

#define IS_HEX(c) (('0' <= c&&c <= '9') || ('a' <= (c)&&(c) <= 'f'))
#define IS_ALGO(c) ((c) == 's' || (c) == 'h' || (c) == 'a')
#define IS_SHAISH(c) (IS_ALGO(c) || IS_HEX(c) || c == ':')
#define SHAISH	    (algo_count == 3 && digest_count == 40)

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
	int algo_count = 0, digest_count = 0, seen_colon;
	char c;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

#define REWIND(c) {							\
	if ((c) == 's')							\
		--p;							\
}

	while ((nread = _read(buf, sizeof SLURP)) > 0) {

		char *p, *p_end;

		p = buf;
		p_end = p + nread;

		while (p < p_end) {
			c = *p++;

			//  most common case is not seen sha:abcd ...

			if (digest_count == 0) {
				if (seen_colon == 0) {
					switch (algo_count) {
					case 0:
						if (c == 's')
							algo_count = 1;
						else
							algo_count = 0;
						break;
					case 1:
						if (c == 'h')
							algo_count = 2;
						else
							algo_count = 0;
						break;
					case 2:
						if (c == 'a')
							algo_count = 3;
						else
							algo_count = 0;
						break;
					case 3:
						if (c == ':')
							seen_colon = 1;
						else
							algo_count = 0;
						break;
					}
					if (algo_count == 0)
						REWIND(c);
				} else if (IS_HEX(c))
					digest_count = 1;
				else {
					REWIND(c);
					algo_count = seen_colon = 0;
				}
			} else if (digest_count < 40) {		//  grumpy gcc
				if (IS_HEX(c)) {
					if (++digest_count == 40)
						_exit(EXIT_MATCH);
				} else {
					digest_count = seen_colon =algo_count=0;
					REWIND(c);
				}
			}
		}
	}
	_exit(EXIT_NO_MATCH);
}
