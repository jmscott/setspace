/*
 *  Synopsis:
 *  	Atomic append of a blob request record to a file.,
 *  Usage:
 *  	append-brr							\
 *		/path/to/file
 *  		start_request_time					\
 *		transport						\
 *		verb							\
 *		algorithm:digest					\
 *		chat_history						\
 *		blob_size						\
 *		wall_duration						\
 *  Exit Status:
 *	0	ok, blob request record appended to file
 *	1	unexpected error
 *  Blame:
 *	jmscott@setspace.com
 *	setspace@gmail.com
 *  Note:
 *  	No syntax checking is done on the fields of the blob request record.
 *  	Only field sizes are checked.  In particular, use _is_udig() in common.c
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
#include <fcntl.h>
#include <string.h>
#include <errno.h>

#include "jmscott/libjmscott.h"

char		*jmscott_progname = "append-brr";
static char	usage[] =
		"append-brr "						\
		"<path/to/file> "					\
		"<start_time> "						\
		"<transport> "						\
		"<verb> "						\
		"<udig> "						\
		"<chat_history> "					\
		"<blob_size> "						\
		"<wall_duration>"
;

#define MAX_BRR		137

static void
die2(char *msg1, char *msg2)
{
	jmscott_die2(1, msg1, msg2);
	/*NOTREACHED*/
}

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
		die2("arg too big for brr field", name); 
	*tgt++ = '\t';
	*brr = tgt;
}

static int
_open(char *path)
{
	int fd = jmscott_open(path,
		   O_WRONLY | O_APPEND | O_CREAT,
		   S_IRUSR | S_IWUSR | S_IRGRP
	);
	if (fd < 0)
		die2("open(append) failed", strerror(errno));
	return fd;
}

static void
_write(int fd, char *buf, size_t nbytes)
{
	if (jmscott_write(fd, buf, nbytes) < 0)
		die2("write(brr) failed", strerror(errno));
}

static void
_close(int fd)
{
	if (jmscott_close(fd))
		die2("close(brr) failed", strerror(errno));
}

int
main(int argc, char **argv)
{
	// room for brr + newline + null
	char brr[MAX_BRR + 1 + 1], *b;
	char *path;
	int fd;

	if (argc != 9)
		jmscott_die_argc(1, argc, 9, usage);
	path = argv[1];

	/*
	 *  Build the blob request record from command line arguments
	 */
	b = brr;
	arg2brr("start time", argv[2], 10+1+8+1+9+1+6, &b);
	arg2brr("transport", argv[3], 8+1+128, &b);
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
