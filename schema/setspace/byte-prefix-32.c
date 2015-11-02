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
#include <string.h>
#include <stdio.h>
#include <errno.h>

#define EXIT_BAD_READ		1
#define EXIT_BAD_WRITE		2
#define EXIT_BAD_ARGC		3

static char progname[] = "byte-prefix-32";

#define COMMON_NEED_READ
#define COMMON_NEED_WRITE
#include "../../common.c"

static char nib2hex[] =
{
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

/*
 *  read() up to 32 bytes from standard input, croaking upon error
 */
static int
read_prefix(void *p)
{
	ssize_t nb, nread = 0;

	again:

	nb = _read(0, p + nread, 32 - nread);
	nread += nb;
	if (nread == 32 || nb == 0)
		return nread;
	goto again;
}

int
main(int argc, char **argv)
{
	unsigned char prefix[32], *p, *p_limit;
	char hex[65], *h;
	int nread;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of command line arguments");
	(void)argv;

	nread = read_prefix(prefix);
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

		_write(1, hex, h - hex);
	}
	_exit(0);
}
