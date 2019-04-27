/*
 *  Synopsis
 *	Remove blob level Test/set lock in run/<lock-name>-<udig>.lock.
 *  Usage:
 *	BLOB=sha:563b8f2dd5e6e2cfff2d40787186124772c562a5
 *	taz-run-lock merge-pddocument $BLOB
 *  Exit Status:
 *	0  -  lock exists and removed
 *	1  -  lock does not exist
 *	2  -  unexpected error
 */

#define EXIT_EXISTS		0
#define EXIT_NO_EXIST		1
#define EXIT_ERR		2

static char *progname = "tas-run-unlock";

#define COMMON_NEED_DIE2
#define COMMON_NEED_IS_UDIG
#define COMMON_NEED_UNLINK

#define EXIT_BAD_CLOSE		EXIT_ERR
#define EXIT_BAD_UNLINK		EXIT_ERR

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

	//  program name includes lock name for easier error messages

	progname_lock[0] = 0;
	_strcat(progname_lock, sizeof progname_lock, "taz-run-unlock: ");
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

	exit(_unlink(path));
}
