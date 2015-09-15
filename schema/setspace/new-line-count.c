/*
 *  Synopsis:
 *	Write count of new-lines (0xa) in stream, assuming stream < 2^63 size.
 *  Exit Code:
 *  	0	ok
 *	1	wrong number of arguments
 *  	2	read on standard input failed
 *	3	write to standard output failed
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 */

#include <string.h>
#include <errno.h>
#include <unistd.h>

#define EXIT_BAD_ARGC		1
#define EXIT_BAD_READ		2
#define EXIT_BAD_WRITE		3

#define SLURP	4096

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
die(int status, char *msg)
{
	static char ERROR[] = "byte-count: ERROR: ";
	char buf[256] = {0};

	_strcat(buf, sizeof buf, ERROR);
	_strcat(buf, sizeof buf, msg);

	write(2, buf, _strcat(buf, sizeof buf, "\n"));
	_exit(status);
}

static void
die2(int status, char *msg1, char *msg2)
{
	char msg[256] = {0};

	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, ": ");
	_strcat(msg, sizeof msg, msg2);

	die(status, msg);
}

static int
_read(char *buf)
{
	int nread;
again:
	nread = read(0, buf, SLURP);
	if (nread >= 0)
		return nread;
	if (errno == EINTR)
		goto again;
	die2(EXIT_BAD_READ, "read(0) failed", strerror(errno));

	//*NOTREACHED*/
	return 0;
}

static void
_write(char *buf, int nbytes)
{
	ssize_t nb;
	void *p;

	p = buf;
again:
	nb = write(1, p, nbytes);
	if (nb < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_WRITE, "write(1) failed", strerror(errno));
	}
	nbytes -= nb;
	if (nbytes > 0) {
		p += nb;
		goto again;
	}
}

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
	while ((nbytes = _read(buf)) > 0) {
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
	_write(buf, nbytes);
	_exit(0);
}
