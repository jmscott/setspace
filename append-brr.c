/*
 *  Synopsis:
 *  	Atomic append of a blob request record to a fifo or file.
 *  Usage:
 *  	append-brr							\
 *		/path/to/file
 *  		start_request_time					\
 *		netflow							\
 *		verb							\
 *		algorithm:digest					\
 *		chat_history						\
 *		blob_size						\
 *		wall_duration						\
 *  Exit Status:
 *	0	ok
 *	1	wrong number of arguments
 *	2	a brr field is too big in the argument list
 *	3	the open() failed
 *	4	the write() failed
 *	5	the close() failed
 *  Blame:
 *	jmscott@setspace.com
 *	setspace@gmail.com
 *  Note:
 *  	No syntax checking is done on the fields of the blob request record.
 *  	Only field sizes are checked.
 *
 *	O_CREAT must be an option on the file open, otherwise rolling the file
 *	is problemmatic.  For example, without O_CREAT, the following
 *	trivial roll will fail for each append()
 *
 *		mv pdf.log pdf-$(date +'%a').log
 *		#  window when an error in append-brr could occur
 *
 *	since pdf.log disappears briefly.
 *
 *	Consider replacing write() with writev().
 */
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <string.h>
#include <errno.h>

#define EXIT_BAD_ARGC	1
#define EXIT_BAD_BRR	2
#define EXIT_BAD_OPEN	3
#define EXIT_BAD_WRITE	4
#define EXIT_NO_ATOMIC	5
#define EXIT_BAD_CLOSE	6

static char	progname[] = "append-brr";

#define COMMON_NEED_WRITE
#define COMMON_NEED_DIE2
#include "common.c"

#define MAX_BRR		365

/*
 *  Build the brr record from a command line argument.
 *  Update the pointer to the position in the buffer.
 *
 *  Note:
 *	Need to be more strict about correctness of brr fields.
 *	For example, a char set per arg would be easy to add.
 */
static void
arg2brr(char *name, char *arg, int size, char **brr)
{
	char *tgt, *src;
	int n;

	n = 0;
	src = arg;
	tgt = *brr;
	while (*src && n++ < size)
		*tgt++ = *src++;
	if (n == size && *src)
		die2(EXIT_BAD_BRR, "arg too big for brr field", name); 
	*tgt++ = '\t';
	*brr = tgt;
}

static void
_close(int fd)
{
	int status;
again:
	status = close(fd);
	if (status == 0)
		return;
	if (errno == EINTR)
		goto again;
	die2(EXIT_BAD_CLOSE, "close() failed", strerror(errno));
}

static int
_open(char *path)
{
	int fd;
again:
	/*
	 *  Open the file append only, possibly creating the file.
	 */
	fd = open(path,
			O_WRONLY | O_APPEND | O_CREAT,
			S_IRUSR | S_IWUSR | S_IRGRP
	);
	if (fd < 0) {
		if (errno == EINTR)
			goto again;
		die2(EXIT_BAD_OPEN, "open() failed", strerror(errno));
	}
	return fd;
}

int
main(int argc, char **argv)
{
	// room for brr + newline + null
	char brr[MAX_BRR + 1 + 1], *b;
	char *path;
	int fd;

	if (argc != 9)
		die(EXIT_BAD_ARGC, "wrong number arguments");
	path = argv[1];

	/*
	 *  Build the blob request record from command line arguments
	 */
	b = brr;
	arg2brr("start request time", argv[2], 10+1+8+1+9+1+6, &b);
	arg2brr("netflow", argv[3], 8+1+128, &b);
	arg2brr("verb", argv[4], 8, &b);
	arg2brr("udig", argv[5], 8+1+128, &b);
	arg2brr("chat history", argv[6], 8, &b);
	arg2brr("blob size", argv[7], 20, &b);
	arg2brr("wall duration", argv[8], 10+1+9, &b);

	b[-1] = '\n';		//  zap trailing tab

	fd = _open(path);

	// atomically write exactly the number bytes in the blob request record
	_write(fd, brr, b - brr);
	_close(fd);
	_exit(0);
}
