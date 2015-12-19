/*
 *  Synopsis:
 *	Write the current time as YYYY-MM-DDThh:mm:ss.ns+00:00 to stdout.
 *  Usage:
 *	NOW=$(RFC3339Nano)
 *  Exit Status:
 *	0	time written
 *	1	bad argument count
 *	2	write to stdout failed
 *	3	failed to aquire current time
 */
#include <time.h>
#include <stdio.h>
#include "macosx.h"

static char 	*progname = "RFC3339Nano";
static char	*RFC3339Nano = "%04d-%02d-%02dT%02d:%02d:%02d.%09ld+00:00\n";

#define EXIT_BAD_ARGC	1
#define EXIT_BAD_WRITE	2
#define EXIT_BAD_TIME	3
#define COMMON_NEED_DIE2
#define COMMON_NEED_WRITE
#include "common.c"

int
main(int argc, char **argv)
{
	char tstamp[512];
	struct timespec	now;
	struct tm *t;
	int nwrite;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number arguments");
	(void)argv;
        if (clock_gettime(CLOCK_REALTIME, &now) < 0)
		die2(EXIT_BAD_TIME,
			"clock_gettime(REALTIME) failed", strerror(errno));
	t = gmtime(&now.tv_sec);
	if (!t)
		die2(EXIT_BAD_TIME, "gmtime() failed", strerror(errno));
	/*
	 *  Format the record buffer.
	 */
	nwrite = snprintf(tstamp, sizeof tstamp, RFC3339Nano,
		t->tm_year + 1900,
		t->tm_mon + 1,
		t->tm_mday,
		t->tm_hour,
		t->tm_min,
		t->tm_sec,
		now.tv_nsec
	);
	_write(1, tstamp, nwrite);
	_exit(0);
}
