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

#define FLIP_BUF() (bp == bufA ? bufB : bufA)

static char nib2hex[] =
{
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

static int
fill(unsigned char *buf, int *pnr)
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
	if (p - buf == 0)
		return 0;
	*pnr = p - buf;
	return 1;
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
	unsigned char bufA[PIPE_MAX], bufB[PIPE_MAX], *bp, *bp1, *bp2;
	int tail_nr;
	int nbuf = 0;
	char hex[65];

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of command line arguments");
	(void)argv;

	//  read exactly PIPE_MAX bytes or read the tail of the blob,
	//  alternating between bufA and bufB.

	bp = bufA;
	while (fill(bp, &tail_nr)) {
		nbuf++;
		if (bp == bufA)
			bp = bufB;
		else
			bp = bufA;
	}

	bp = (bp == bufA ? bufB : bufA);

	//  final read() of blob got at least 32 bytes

	if (tail_nr >= 32)
		put_hex(hex, bp + tail_nr - 32, 32);
	
	//  zero length blob

	if (nbuf == 0)
		_exit(0);

	//  total blob size < 32 bytes

	if (nbuf == 1)
		put_hex(hex, bp, tail_nr);

	//  we now know that the suffix will be exactly 32 bytes.

	//  is the suffix entirely in the previous block

	if (tail_nr == PIPE_MAX)
		put_hex(hex, bp + PIPE_MAX - 32, 32);

	//  tail block was read less than PIPE_MAX bytes, so 32 byte suffix
	//  spans final two chunks, where the length of tail chunk is 0 <&&< 32
	//  bytes and that the length of previous chunk is exactly PIPE_MAX
	//  bytes.

	if (bp == bufA) {
		bp1 = bufB;
		bp2 = bufA;
	} else {
		bp1 = bufA;
		bp2 = bufB;
	}

	byte2hex(hex, bp1 + (PIPE_MAX - (32 - tail_nr)), 32 - tail_nr);
	byte2hex(hex + (64 - tail_nr * 2), bp2, tail_nr);
	hex[64] = '\n';
	_write(1, hex, 65);
	_exit(0);
}
