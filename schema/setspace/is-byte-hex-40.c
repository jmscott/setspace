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
#include <unistd.h>

#define IS_HEX(c) (('0' <= c&&c <= '9') || ('a' <= (c)&&(c) <= 'f'))

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
	int hex_count = 0;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

	while ((nread = _read(buf, sizeof SLURP)) > 0) {

		char *p, *p_end;

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
