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
 *	Rename common.c to unistd.c?
 */
#include <unistd.h>

#ifndef PIPE_MAX
#define PIPE_MAX	512
#endif

#if defined(COMMON_NEED_READ) || defined(COMMON_NEED_WRITE) ||		\
    defined(COMMON_NEED_CLOSE) || defined(COMMON_NEED_FCHMOD)

#define COMMON_NEED_DIE2

#endif

#if defined(COMMON_NEED_OPEN)
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
