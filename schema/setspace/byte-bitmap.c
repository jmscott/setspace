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
#include <unistd.h>
#include <string.h>
#include <errno.h>

#define EXIT_BAD_READ		1
#define EXIT_BAD_WRITE	2

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
	static char ERROR[] = "byte-bitmap: ERROR: ";
	char msg[256] = {0};

	_strcat(msg, sizeof msg, ERROR);
	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, ": ");
	_strcat(msg, sizeof msg, msg2);

	write(2, msg, _strcat(msg, sizeof msg, "\n"));

	_exit(status);
}

/*
 *  read() up to 'nbytes' from standard input, croaking upon error
 */

static int
_read(void *p, ssize_t nbytes)
{
	ssize_t nb;

	again:

	nb = read(0, p, nbytes);
	if (nb >= 0)
		return nb;
	if (errno == EINTR)		//  try read()
		goto again;

	die2(EXIT_BAD_READ, "read(0) failed", strerror(errno));

	/*NOTREACHED*/
	return -1;
}

/*
 *  write() exactly nbytes to standard output or croak with error
 */
static void
_write(void *p, ssize_t nbytes)
{
	int nb = 0;

	again:

	nb = write(1, p + nb, nbytes);
	if (nb < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_WRITE, "write(1) failed", strerror(errno));
	}
	nbytes -= nb;
	if (nbytes > 0)
		goto again;
}

int
main() {

	unsigned char map[32] = {0}, buf[4096], *p, *p_limit;
	char hex[65], *h;
	int nb;

	bzero(map, 32);		// is map[]={0} valid for stack vars?

	while ((nb = _read(buf, sizeof buf)) > 0) {

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

	_write(hex, 65);
	_exit(0);
}
