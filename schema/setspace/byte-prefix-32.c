/*
 *  Synopsis:
 *	Write the 32 byte prefix of the blob as ascii hexidecimal
 *  Blame:
 *  	jmscott@setspace.com
 *  Exit Status:
 *  	0	ok, wrote prefix
 *  	1	error reading standard input
 *  	2	error writing standard output
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>

#define EXIT_BAD_READ		1
#define EXIT_BAD_WRITE		2

static char nib2hex[] =
{
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

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
die2(int status, char *msg1, char *msg2)
{
	static char ERROR[] = "byte-prefix-32: ERROR: ";
	char msg[256] = {0};

	_strcat(msg, sizeof msg, ERROR);
	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, ": ");
	_strcat(msg, sizeof msg, msg2);

	write(2, msg, _strcat(msg, sizeof msg, "\n"));

	_exit(status);
}

/*
 *  read() up to 32 bytes from standard input, croaking upon error
 */
static int
_read(void *p)
{
	ssize_t nb, nread = 0;

	again:

	nb = read(0, p + nread, 32 - nread);
	if (nb < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_READ, "read(0) failed", strerror(errno));
	}
	nread += nb;
	if (nread == 32 || nb == 0)
		return nread;
	goto again;
}

/*
 *  write() exactly nbytes to standard output or croak with error
 */
static void
_write(void *p, ssize_t nwrite)
{
	int nb = 0;

	again:

	nb = write(1, p, nwrite);
	if (nb < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_WRITE, "write(1) failed", strerror(errno));
	}
	nwrite -= nb;
	p += nb;
	if (nwrite > 0)
		goto again;
}

int
main()
{
	unsigned char prefix[32], *p, *p_limit;
	char hex[65], *h;
	int nread;

	nread = _read(prefix);
	if (nread > 0) {
		p = prefix;
		p_limit = prefix + 32;
		h = hex;
		while (p < p_limit) {
			*h++ = nib2hex[(*p & 0xf0) >> 4];
			*h++ = nib2hex[*p & 0xf];
			p++;
		}
		*h++ = '\n';

		_write(hex, h - hex);
	}
	_exit(0);
}
