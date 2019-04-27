/*
 *  Synopsis
 *	Create blob level test/set lock in run/<lock-name>-<udig>.lock.
 *  Usage:
 *	BLOB=sha:563b8f2dd5e6e2cfff2d40787186124772c562a5
 *	taz-run-lock merge-pddocument $BLOB
 *  Exit Status:
 *	0  -  no lock exists, so create lock in run/<lock-name>-<udig>.lock
 *	1  -  lock already exists
 *	2  -  unexpected error
 */

#define EXIT_CREATED		0
#define EXIT_EXISTS		1
#define EXIT_ERR		2

static char *progname = "tas-run-lock";

#define COMMON_NEED_DIE2
#define COMMON_NEED_DIE3
#define COMMON_NEED_IS_UDIG
#define COMMON_NEED_CLOSE

#define EXIT_BAD_CLOSE		EXIT_ERR

#include "common.c"

int
main(int argc, char **argv)
{
	char *lock_name, *blob;
	char path[
		4 +	//  "run/"
		127 + 	//  maximum length of lock name
		1 +	//  "-"
		137 +	//  maximum udig
		5 +	//  ".lock"
		1	//  zero byte
	];
	int fd;

	//  program name includes the lock name for error messages.
	static char progname_lock[
		14  +	//  "tas-run-lock: "
		127 +	//  maximum length of lock name
		1	//  zero byte
	];

	if (argc != 3)
		die(EXIT_ERR, "wrong number of command arguments");

	lock_name = argv[1];
	if (!lock_name[0])
		die(EXIT_ERR, "empty lock name");
	if (strlen(lock_name) > 127)
		die2(EXIT_ERR, "lock name > 127 bytes", lock_name);
	progname_lock[0] = 0;
	_strcat(progname_lock, sizeof progname_lock, "taz-run-lock: ");
	_strcat(progname_lock, sizeof progname_lock, lock_name);
	progname = progname_lock; 

	blob = argv[2];
	if (_is_udig(blob) == 0)
		die2(EXIT_ERR, "blob is not a udig", blob);

	path[0] = 0;
	_strcat(path, sizeof path, "run/");
	_strcat(path, sizeof path, lock_name);
	_strcat(path, sizeof path, "-");
	_strcat(path, sizeof path, blob);
	_strcat(path, sizeof path, ".lock");
again:
	fd = open(path, O_CREAT | O_EXCL, 0644);
	if (fd < 0) {
		if (errno == EEXIST)
			exit(EXIT_EXISTS);
		if (errno == EINTR)
			goto again;
		die3(EXIT_ERR, "open(lock) failed", lock_name,strerror(errno));
	}
	_close(fd);
	exit(EXIT_CREATED);
}
