/*
 *  Synopsis:
 *	Write the file size in bytes on standard output
 *  Usage:
 *	file-stat-size <path-to-file>
 *  Exit Status
 *	0	size written to standard out
 *	1	stat() error
 *	2	wrong number of arguments
 *	3	write(stdout) failed
 */
#include <sys/stat.h>

static char *progname = "file-stat-size";

#define EXIT_OK		0
#define EXIT_BAD_STAT	1
#define EXIT_BAD_ARGC	2
#define EXIT_BAD_WRITE	3

#define COMMON_NEED_DIE3
#define COMMON_NEED_ULLTOA
#define COMMON_NEED_WRITE
#include "common.c"

int
main(int argc, char **argv)
{
	char *path;
	struct stat st;
	char digits[128], *p;

	if (argc != 2)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	path = argv[1];

	/*
	 *  Stat the file to get the size.
	 */
	if (stat(path, &st) != 0)
		die3(EXIT_BAD_STAT, path, "stat() failed", strerror(errno));

	/*
	 *  Convert size to decimal digit string.
	 */
	p = ulltoa((unsigned long long)st.st_size, digits);
	*p++ = '\n';

	_write(1, digits, p - digits);
	_exit(EXIT_OK);
}
