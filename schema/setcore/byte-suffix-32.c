/*
 *  Synopsis:
 *	Write the hexidecimal value of the up to the final 32 bytes of a blob.
 *  Usage:
 *	byte-suffix-32 <path/to/blob>
 *  Exit Status:
 *  	0	ok, wrote suffix
 *	1	unknown error
 *  Note:
 *	Replaced ../../common.s with using libjmscott functions.
 */
#include <string.h>
#include <errno.h>
#include <fcntl.h>

#include "jmscott/libjmscott.h"

extern int	errno;

char *jmscott_progname = "byte-suffix-32";

static char nib2hex[] =
{
	'0', '1', '2', '3', '4', '5', '6', '7', '8', '9',
	'a', 'b', 'c', 'd', 'e', 'f'
};

static void
byte2hex(unsigned char *tgt, unsigned char *src, size_t nbytes)
{
	unsigned char *src_limit;

	src_limit = src + nbytes;
	while (src < src_limit) {
		*tgt++ = nib2hex[(*src & 0xf0) >> 4];
		*tgt++ = nib2hex[*src & 0xf];
		src++;
	}
	*tgt = '\n';
}

static void
die(char *msg)
{
	if (errno > 0)
		jmscott_die2(1, msg, strerror(errno));
	else
		jmscott_die(1, msg);
}

static void
die2(char *msg1, char *msg2)
{
	if (errno > 0)
		jmscott_die3(1, msg1, msg2, strerror(errno));
	else
		jmscott_die2(1, msg1, msg2);
}

static void
diea(int argc)
{
	jmscott_die_argc(1, argc, 1, "byte-suffix-32 <path/to/blob>");
}

int
main(int argc, char **argv)
{
	unsigned char buf[32];
	unsigned char hex[32+32+1];		//  no zero termination

	if (argc != 2)
		diea(argc);
	(void)argv;
	jmscott_close(0);

	char *path = argv[1];
	int in = jmscott_open(path, O_RDONLY, 0);
	if (in < 0)
		die("open(blob) failed");

	struct stat st;
	if (jmscott_fstat(in, &st) < 0)
		die("fstat(in) failed");
	if (st.st_size == 0)
		_exit(0);

	size_t nb = 32;
	if (st.st_size > 32) {
		off_t off = st.st_size - 32;
		if (jmscott_lseek(in, off, SEEK_CUR) < 0)
			die("lseek(blob) failed");
	} else
		nb = st.st_size;

	errno = 0;
	switch (jmscott_read_exact(in, (void *)buf, nb)) {
	case 0:
		break;
	case -1:
		die2("read(in:<=32) failed", strerror(errno));
		/* NOTREACHED */
		break;
	case -2:
		die("read(in:<=32): unexpected end of file");
		/*NOTREACHED */
		break;
	}

	byte2hex(hex, buf, nb);
	if (jmscott_write(1, hex, nb * 2 + 1) < 0)
		die("write(hex) failed");

	_exit(0);
}
