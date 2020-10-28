/*
 *  Synopsis:
 *	Naive counting of ones bits read from standard input, as int64.
 *  Usage:
 *	BIT_COUNT=$(bio-cat sha:abcd... | bit-count)
 *  Exit Status:
 *  	0	ok
 *	1	additive overflow
 *  	2	read on standard input failed
 *	3	write to standard output failed
 *	4	wrong number of arguments
 *  See:
 *	https://graphics.stanford.edu/~seander/bithacks.html
 */

#include <string.h>
#include <errno.h>

#define EXIT_ADD_OVERFLOW	1
#define EXIT_BAD_READ		2
#define EXIT_BAD_WRITE		3
#define EXIT_BAD_ARGC		4

static char progname[] = "bit-count";

#define COMMON_NEED_READ
#define COMMON_NEED_WRITE
#include "../../common.c"

#define SLURP	4096

int
main(int argc, char **argv)
{
	char buf[SLURP], *p;
	unsigned long long count;
	long long tmp;
	int nb;
	char const digit[] = "0123456789";
	unsigned char bits_per_byte[256];

	(void)(argv);
	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");

	bits_per_byte[0] = 0;
	for (int i = 0; i < 256; i++)
		bits_per_byte[i] = (i & 1) + bits_per_byte[i / 2];

	/*
	 *  Count all the ones-bits read on standard input.
	 */
	count = 0;
	while ((nb = _read(0, buf, sizeof buf)) > 0)
		for (int i = 0;  i < nb;  i++)
			count += bits_per_byte[(unsigned char)buf[i]];
	if (count > 9223372036854775807)
		_exit(EXIT_ADD_OVERFLOW);

	/*
	 *  Build the ascii version of the bit count.
	 *
	 *  First count the digits and terminate the buffer with a new-line
	 *  and null.
	 */
	p = buf;
	tmp = count;
	do
	{
		p++;
		tmp = tmp / 10;

	} while (tmp > 0);
	*p = '\n';
	p[1] = 0;
	nb = p - buf + 1;

	/*
	 *  Fill in digits, from least to most signficant.
	 */
	do
	{
		*--p = digit[count % 10];
		count = count / 10;
	} while (count > 0);

	_write(1, buf, nb);
	_exit(0);
}
