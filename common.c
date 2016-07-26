/*
 *  Synopsis:
 *	Common, interruptable system calls, die[123]() and _strcat().
 *  Usage:
 *	char *progname = "append-brr";
 *
 *	#define COMMON_NEED_READ
 *	#define COMMON_NEED_DIE3
 *	#include "../../common.c"
 *
 *	#define COMMON_NEED_READ
 *	#define EXIT_BAD_READ 4
 *	#include "../../common.c"
 *  See:
 *	flip-tail and c programs in schema directories.
 *  Note:
 *	Rename common.c to unistd.c or common-cli.c?
 */
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <strings.h>
#include <stdlib.h>

//  Note: should be PIPE_BUF or MAX_MSG_SIZE?

#ifndef PIPE_MAX
#define PIPE_MAX	4096
#endif

#if defined(COMMON_NEED_READ)					||	\
    defined(COMMON_NEED_READ_BLOB)				||	\
    defined(COMMON_NEED_WRITE) 					||	\
    defined(COMMON_NEED_CLOSE)					||	\
    defined(COMMON_NEED_FCHMOD)

#define COMMON_NEED_DIE2

#endif

#if defined(COMMON_NEED_OPEN)
#define COMMON_NEED_DIE3
#endif

#if defined(COMMON_NEED_READ_BLOB)
#define COMMON_NEED_READ
#endif

#if defined(COMMON_NEED_A2UI32)
#define COMMON_NEED_DIE3
#endif

/*
 * Synopsis:
 *  	Fast, safe and simple string concatenator
 *  Usage:
 *  	buf[0] = 0
 *  	_strcat(buf, sizeof buf, "hello, world");
 *  	_strcat(buf, sizeof buf, ": ");
 *  	_strcat(buf, sizeof buf, "good bye, cruel world");
 */
static void
_strcat(char *tgt, int tgtsize, char *src)
{
	//  find null terminated end of target buffer
	while (*tgt++)
		--tgtsize;
	--tgt;

	//  copy non-null src bytes, leaving room for trailing null
	while (--tgtsize > 0 && *src)
		*tgt++ = *src++;

	// target always null terminated
	*tgt = 0;
}

/*
 *  Write error message to standard error and exit process with status code.
 */
static void
die(int status, char *msg1)
{
	char msg[PIPE_MAX];
	static char ERROR[] = "ERROR: ";
	static char	colon[] = ": ";
	static char nl[] = "\n";

	msg[0] = 0;
	_strcat(msg, sizeof msg, progname);
	_strcat(msg, sizeof msg, colon);
	_strcat(msg, sizeof msg, ERROR);
	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, nl);

	write(2, msg, strlen(msg));

	_exit(status);
}

#ifdef COMMON_NEED_DIE2

static void
die2(int status, char *msg1, char *msg2)
{
	static char colon[] = ": ";
	char msg[PIPE_MAX];

	msg[0] = 0;
	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, colon);
	_strcat(msg, sizeof msg, msg2);

	die(status, msg);
}
#endif

#ifdef COMMON_NEED_DIE3
static void
die3(int status, char *msg1, char *msg2, char *msg3)
{
	static char colon[] = ": ";
	char msg[PIPE_MAX];

	msg[0] = 0;
	_strcat(msg, sizeof msg, msg1);
	_strcat(msg, sizeof msg, colon);
	_strcat(msg, sizeof msg, msg2);
	_strcat(msg, sizeof msg, colon);
	_strcat(msg, sizeof msg, msg3);

	die(status, msg);
}
#endif

/*
 *  To include _read() add the following to source which includes
 *  this file:
 *
 *	#define COMMON_NEED_READ
 *	#define EXIT_BAD_READ 3		//  any code is ok
 */
#ifdef COMMON_NEED_READ

/*
 *  read() bytes from file fd, restarting on interrupt and dieing on error.
 */
static int
_read(int fd, void *p, ssize_t nbytes)
{
	ssize_t nb;

	again:

	nb = read(fd, p, nbytes);
	if (nb >= 0)
		return nb;
	if (errno == EINTR)		//  try read()
		goto again;

	die2(EXIT_BAD_READ, "read() failed", strerror(errno));

	/*NOTREACHED*/
	return -1;
}
#endif

/*
 *  To include _read() add the following to source which includes
 *  this file:
 *
 *	#define COMMON_NEED_READ_BLOB
 *	#define EXIT_BLOB_SMALL 4		//  any code is ok
 *	#define EXIT_BLOB_BIG 5			//  any code is ok
 */
#ifdef COMMON_NEED_READ_BLOB

/*
 *  _read() exactly n bytes from fd, die() if too few or too many bytes exist.
 *
 *  Note:
 *	the name "_read_blob" implies we ought to also verify the blob.
 *	maybe something like _read_exact() would be a better name?
 */
static void
_read_blob(int fd, void *blob, ssize_t size)
{
	int nread = 0, nr;

again:
	nr = _read(fd, blob + nread, size - nread);
	if (nr > 0) {
		nread += nr;
		if (nread < size)
			goto again;
	}
	if (nread < size)
		die(EXIT_BLOB_SMALL, "blob too small");
	/*
	 * Verify no bytes remain
	 */
	if (_read(fd, blob, 1) != 0)
		die(EXIT_BLOB_BIG, "blob too big");
}

#endif

/*
 *  To include _write() add the following to source which includes
 *  this file:
 *
 *	#define COMMON_NEED_WRITE
 *	#define EXIT_BAD_WRITE 4		//  any code is ok
 */
#ifdef COMMON_NEED_WRITE

/*
 *  write() exactly nbytes bytes, restarting on interrupt and dieing on error.
 */
static void
_write(int fd, void *p, ssize_t nbytes)
{
	int nb = 0;

	again:

	nb = write(fd, p + nb, nbytes);
	if (nb < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_WRITE, "write() failed", strerror(errno));
	}
	nbytes -= nb;
	if (nbytes > 0)
		goto again;
}

#endif

/*
 *  To include _open() add the following to source which includes
 *  this file:
 *
 *	#define COMMON_NEED_OPEN
 *	#define EXIT_BAD_OPEN 4		//  any code is ok
 */
#ifdef COMMON_NEED_OPEN

/*
 *  open() a file.
 */
static int
_open(char *path, int oflag, int mode)
{
	int fd;

	again:

	fd = open(path, oflag, mode);
	if (fd < 0) {
		if (errno == EINTR)
			goto again;
		die3(EXIT_BAD_OPEN, "open() failed", strerror(errno), path);
	}
	return fd;
}

#endif

/*
 *  To include _close() add the following to source which includes
 *  this file:
 *
 *	#define COMMON_NEED_OPEN
 *	#define EXIT_BAD_OPEN 4		//  any code is ok
 */
#ifdef COMMON_NEED_CLOSE

/*
 *  close() a file descriptor.
 */
static void
_close(int fd)
{
	again:

	if (close(fd) < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_CLOSE, "close() failed", strerror(errno));
	}
}

#endif

/*
 *  To include _fchmod() add the following to source which includes
 *  this file:
 *
 *	#define COMMON_NEED_FCHMOD
 *	#define EXIT_BAD_FCHMOD 11		//  any code is ok
 */
#ifdef COMMON_NEED_FCHMOD

static void
_fchmod(int fd, int mode)
{
	again:

	if (fchmod(fd, mode) < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_FCHMOD, "fchmod() failed", strerror(errno));
	}
}

#endif

#ifdef COMMON_NEED_ULLTOA

/*
 *  Convert unsigned long long to decimal ascii string.
 *  Return the pointer to byte after final digit:
 *
 *	*ulltoa(ull, digits) = 0;
 */
static char *
ulltoa(unsigned long long ull, char *digits)
{
	char const digit[] = "0123456789";
	char* p, *end_p;
	unsigned long long power = ull;

	//  find the end of the formated ascii string

	p = digits;
	do
	{
		++p;
		power = power / 10;

	} while (power);
	end_p = p;

	//  in reverse order, replace byte with the ascii chars

	do
	{
		*--p = digit[ull % 10];
		ull = ull / 10;

	} while (ull);
	return end_p;
}

#endif

#ifdef COMMON_NEED_A2UI32

/*
 *  Synopsis:
 *	Strictly parse an ascii string representing an unsigned 32 bit int
 *	in the range 0 <= 4294967295.  die() upon error.
 *  Usage:
 *	blob_size = a2ui32(argv[1], "blob size", 1);
 */
unsigned int
a2ui32(char *src, char *what, int die_status)
{
	int len = 0; 
	char *p = src, c;
	long ll;

	/*
	 *  Note:
	 *	Must be a compile time option!
	 */
	if (sizeof (long int) < 8)
		die(255, "sizeof (long int) < 8");

	//  verify source is <= 10 digits

	while ((c = *p++)) {
		if (c < '0' || c > '9')
			die3(die_status, what, "not a cardinal number", src);
		if (len++ > 10)
			die3(die_status, what, "cardinal > 10 digits", src);
	}

	//  build the long long int number

	ll = 0;
	p = src;
	while ((c = *p++))
		ll = ll * 10 + (c - '0');

	//  is the number too big?

	if (ll > 4294967295)
		die2(die_status, what, "> 4294967295");
	return (unsigned int)ll;
}

#endif

#ifdef COMMON_NEED_HEXDUMP

#include <ctype.h>
#include <stdio.h>

/*
 *  Ye'ol hex dump.
 *
 *  Derived from a hexdump written by Andy Fullford, eons ago.
 *
 *  	https://github.com/akfullfo
 */
void
hexdump(int fd, unsigned char *src, int src_size, char direction)
{
	char *t;
	unsigned char *s, *s_end;
	int need;
	char tbuf[64 * 1024], *tgt;
	int tgt_size;
	char buf[1024];

	if (src_size == 0) {
		static char zero[] = "hexdump: 0 bytes in source buffer\n";
		write(fd, zero, sizeof zero - 1);
		return;
	}

	tgt = tbuf;
	tgt_size = sizeof tbuf;

	static char hexchar[] = "0123456789abcdef";

	/*
	 *  Insure we have plenty of room in the target buffer.
	 *
	 *  Each line of ascii output formats up to 16 bytes in the source
	 *  buffer, so the number of lines is the ceiling(src_size/16).
	 *  The number of characters per line is 76 characters plus the 
	 *  trailing new line.
	 *
	 *	((src_size - 1) / 16 + 1) * (76 + 1) + 1
	 *
	 *  with the entire ascii string terminated with a null byte.
	 */
	need = ((src_size - 1) / 16 + 1) * (76 + 1) + 1;

	/*
	 *  Not enough space in the target buffer ... probably ought
	 *  to truncate instead of punting.
	 */
	if (need > tgt_size) {
		snprintf(tgt, tgt_size,
			"hexdump: source bigger than target: %d > %d\n", need,
				tgt_size);
		write(fd, tgt, strlen(tgt));
		return;
	}

	s = src;
	s_end = s + src_size;
	t = tgt;

	while (s < s_end) {
		int i;

		/*
		 *  Start of line in the target.
		 */
		char *l = t;

		/*
		 *  Write the offset into the source buffer.
		 */
		sprintf(l, "%6lu", (long unsigned)(s - src));

		/*
		 *  Write direction of flow
		 */
		l[6] = l[7] = ' ';
		l[8] = direction;
		l[9] = ' ';

		/*
		 *  Format up to next 16 bytes from the source.
		 */
		for (i = 0;  s < s_end && i < 16;  i++) {
			l[10 + i * 3] = ' ';
			l[10 + i * 3 + 1] = hexchar[(*s >> 4) & 0x0F];
			l[10 + i * 3 + 2] = hexchar[*s & 0x0F];
			if (isprint(*s))
				l[60 + i] = *s;
			else
				l[60 + i] = '.';
			s++;
		}
		/*
		 *  Pad out last line with white space.
		 */
		while (i < 16) {
			l[10 + i * 3] =
			l[10 + i * 3 + 1] =
			l[10 + i * 3 + 2] = ' ';
			l[60 + i] = ' ';
			i++;
		}
		l[58] = l[59] = ' ';
		l[76] = '\n';
		t = l + 77;
	}
	tgt[need - 1] = 0;

	snprintf(buf, sizeof buf, "\ndump of %d bytes\n", src_size);
	write(fd, buf, strlen(buf));
	write(fd, tgt, strlen(tgt));
	write(fd, "\n", 1);
}

#endif
