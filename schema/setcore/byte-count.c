/*
 *  Synopsis:
 *	Write to stdout ascii int64 count of bytes read from stdin
 *  Exit Status:
 *  	0	ok
 *	1	additive overflow
 *  	2	read on standard input failed
 *	3	write to standard output failed
 *	4	wrong number of arguments
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

#include <string.h>
#include <errno.h>

#define EXIT_ADD_OVERFLOW	1
#define EXIT_BAD_READ		2
#define EXIT_BAD_WRITE		3
#define EXIT_BAD_ARGC		4

static char progname[] = "byte-count";

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
	 *  Count the bytes read on standard input.
	 */
	count = 0;
	while ((nbytes = _read(0, buf, sizeof buf)) > 0) {
		count += nbytes;
		if (count > 9223372036854775807)
			_exit(EXIT_ADD_OVERFLOW);
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
