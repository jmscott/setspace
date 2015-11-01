/*
 *  Synopsis:
 *	Routines shared by most simple c programs, many in schema/...*.c
 *  Usage:
 *	char *progname = "append-brr";
 *
 *	#include "../../common.c"
 *  See:
 *	schema/...*.c
 */
#include <unistd.h>

#ifndef PIPE_MAX
#define PIPE_MAX	512
#endif

static char	colon[] = ": ";

/*
 * Synopsis:
 *  	Safe & simple string concatenator
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

#ifndef COMMON_NO_NEED_DIE2
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
