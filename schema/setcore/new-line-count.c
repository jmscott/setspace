/*
 *  Synopsis:
 *	Write count of new-lines (0xa) in stream, assuming stream < 2^63 size.
 *  Exit Code:
 *  	0	ok
 *	1	wrong number of arguments
 *  	2	read on standard input failed
 *	3	write to standard output failed
 *  Note:
 *	The newline count is byte oriented.  No assumption is made about
 *	the structure of the stream of bytes.
 */

#include <string.h>
#include <errno.h>

static char progname[] = "new-line-count";

#define EXIT_BAD_ARGC		1
#define EXIT_BAD_READ		2
#define EXIT_BAD_WRITE		3

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
	int nbytes;
	char const digit[] = "0123456789";

	(void)(argv);
	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");

	/*
	 *  Count the new-lines read on standard input.
	 */
	count = 0;
	while ((nbytes = _read(0, buf, sizeof buf)) > 0) {
		char *p = buf;

		while (nbytes-- > 0)
			if (*p++ == '\n')
				count++;
	}

	/*
	 *  Build the ascii version of the byte count.
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
	nbytes = p - buf + 1;

	/*
	 *  Fill in the digits.
	 */
	do
	{
		*--p = digit[count % 10];
		count = count / 10;
	}
	while (count > 0);
	_write(1, buf, nbytes);
	_exit(0);
}
