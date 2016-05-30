/*
 *  Synopsis:
 *	Write the 32 byte suffix of the blob as ascii hexidecimal
 *  Blame:
 *  	jmscott@setspace.com
 *  Exit Status:
 *  	0	ok, wrote suffix
 *	1	bad argument count on command line
 *  	2	error reading standard input
 *  	3	error writing standard output
 */
#include <string.h>
#include <stdio.h>
#include <errno.h>

#define EXIT_BAD_ARGC		1
#define EXIT_BAD_READ		2
#define EXIT_BAD_WRITE		3

static char progname[] = "byte-suffix-32";

#define COMMON_NEED_READ
#define COMMON_NEED_WRITE
#include "../../common.c"

static char nib2hex[] =
{
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

static int fill(unsigned char *buf)
{
	unsigned char *p, *p_limit;

	p = buf;
	p_limit = buf + PIPE_MAX;
	while (p < p_limit) {
		int nr;

		nr = _read(0, p, p_limit - p);
		if (nr == 0)
			break;
		p += nr;
	}
	return p - buf;
}

static void
byte2hex(char *tgt, unsigned char *src, int nbytes)
{
	unsigned char *src_limit;

	src_limit = src + nbytes;
	while (src < src_limit) {
		*tgt++ = nib2hex[(*src & 0xf0) >> 4];
		*tgt++ = nib2hex[*src & 0xf];
		src++;
	}
}

//  convert bytes to hex, write to standard out and exit

static void
put_hex(char *hex, unsigned char *bp, int nbytes)
{
	int nhex = nbytes * 2;

	byte2hex(hex, bp, nbytes);
	hex[nhex] = '\n';
	_write(1, hex, nhex + 1);
	_exit(0);
}

int
main(int argc, char **argv)
{
	unsigned char buf1[PIPE_MAX], buf2[PIPE_MAX], *bp;
	int nr, nbuf = 0;
	char hex[65];

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of command line arguments");
	(void)argv;

	//  read exactly PIPE_MAX bytes or read the tail of the input,
	//  alternating between buf1 and buf2.

	bp = buf1;
	while ((nr = fill(bp)) > 0) {
		nbuf++;
		if (bp == buf1)
			bp = buf2;
		else
			bp = buf1;
	}

	//  final read() of blob got at least 32 bytes

	if (nr >= 32)
		put_hex(hex, bp + nr - 32, 32);
	
	//  zero length blob

	if (nbuf == 0)
		_exit(0);


	//  total blob size < 32 bytes

	if (nbuf == 1)
		put_hex(hex, bp, nr);

	//  is the suffix entirely in the previous block

	if (nr == 0) {
		if (bp == buf1)
			put_hex(hex, buf2 + PIPE_MAX - 32, 32);
		put_hex(hex, buf1 + PIPE_MAX - 32, 32);
	}

	//  suffix is in both previous chunk and final chunk

	_exit(0);
}
