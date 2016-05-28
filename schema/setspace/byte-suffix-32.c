/*
 *  Synopsis:
 *	Write the 32 byte suffix of the blob as ascii hexidecimal
 *  Blame:
 *  	jmscott@setspace.com
 *  Exit Status:
 *  	0	ok, wrote suffix
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

static char progname[] = "byte-suffix-32";

#define COMMON_NEED_READ
//  #define COMMON_NEED_WRITE
#include "../../common.c"

static int fill(unsigned char *buf, int size)
{
	unsigned char *p, *p_limit;

	p = buf;
	p_limit = buf + size;
	while (p < p_limit) {
		int nr;

		nr = _read(0, p, p_limit - p);
		if (nr == 0)
			break;
		p += nr;
	}
	return p - buf;
}

int
main(int argc, char **argv)
{
	unsigned char buf1[PIPE_MAX], buf2[PIPE_MAX], *bp;
	int nr1, nr2, *pnr;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of command line arguments");
	(void)argv;

	bp = buf1;
	pnr = &nr1;

	while ((*pnr = fill(bp, PIPE_MAX)) > 0)
		if (bp == buf1) {
			bp = buf2;
			pnr = &nr2;
		} else {
			bp = buf1;
			pnr = &nr1;
		}
	_exit(0);
}
