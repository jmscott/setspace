/*
 *  Synopsis:
 *	Write a 256 bit histogram in ascii hex of bytes read from standard in
 *  Blame:
 *  	jmscott@setspace.com
 *  Exit Status:
 *  	0	ok, wrote 32 byte, bitmap map as hexidecimal string.
 *  	1	error reading standard input
 *  	2	error writing standard output
 *  Usage:
 *	echo hello, world | byte-bitmap
 *	HEX=$(byte-bitmap <blob)
 *	STATUS=$?
 *	test $STATUS = 0 || exit $STATUS
 *	echo "0x$HEX"
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */
#include <string.h>
#include <errno.h>

static char progname[] = "byte-bitmap";

#define COMMON_NEED_READ
#define COMMON_NEED_DIE2
#define EXIT_BAD_READ		1

#define COMMON_NEED_WRITE
#define EXIT_BAD_WRITE		2

#include "../../common.c"

static char nib2hex[] =
{
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

int
main() {

	unsigned char map[32] = {0}, buf[4096], *p, *p_limit;
	char hex[65], *h;
	int nb;

	bzero(map, 32);		// is map[]={0} valid for stack vars?

	while ((nb = _read(0, buf, sizeof buf)) > 0) {

		unsigned char c;

		p = buf;
		p_limit = buf + nb;

		while (p < p_limit) {
			c = *p++;
			map[c / 8] |= 0x1 << (c % 8);
		}
	}

	//  convert the bitmap to hexdecimal ascii

	p = map;
	p_limit = map + 32;
	h = hex + 65;
	*--h = '\n';
	while (p < p_limit) {
		*--h = nib2hex[*p & 0xf];
		*--h = nib2hex[(*p & 0xf0) >> 4];
		p++;
	}

	_write(1, hex, 65);
	_exit(0);
}
