/*
 *  Synopsis:
 *	Roll an active file being tailed to archive and then reopen active.
 *  Usage:
 *	ACTIVE=spool/fffile5.brr
 *	ARCHIVE=spool/fffile5--$(date +'%Y%m%d_%H%M%S').brr
 *  	roll-tail $SRC $TGT
 *
 *  Arguments:
 *  	active path	path to active file
 *  	archive path	archive path of rolled file
 *
 *  Exit Status:
 *  	0	success, the new file was created and was of the requested type
 *  	1	new active file already exists (ok) and is regular file
 *	2	unexpected error
 *  See:
 *	script brr-flip
 *  Note:
 *	Rename to "roll-tail-file".
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <errno.h>
#include <string.h>
#include <stdio.h>

#include "jmscott/libjmscott.h"

#define EXIT_OK		0
#define EXIT_NEW_EXISTS	1
#define EXIT_ERROR	2

char *jmscott_progname = "flip-tail";
static char *usage = "flip-tail [active path] [archive path]";

static void
die(char *msg)
{
	jmscott_die(EXIT_ERROR, msg);
}

static void
die2(char *msg1, char *msg2)
{
	jmscott_die2(EXIT_ERROR, msg1, msg2);
}

int
main(int argc, char **argv)
{
	char *active_path, *archive_path;
	int fd_active = -1;
	int exit_status = EXIT_OK;
	struct stat st;

	if (argc != 3)
		jmscott_die_argc(EXIT_ERROR, argc, 3, usage);

	active_path = argv[1];
	archive_path = argv[2];

	/*
	 *  Open an existing, active file, holding open to prevent deletion of
	 *  the underlying inode by another process.
	 */
	fd_active = jmscott_open(active_path, O_WRONLY, 0);
	if (fd_active < 0)
		die2("open(active) failed", strerror(errno));

	/*
	 *  Rename the active path to the archive path, effectively hiding the
	 *  inode from further writes.  Remember what ever is reading the file
	 *  (usually flowd) won't actually flip until the inode - not the path -
	 *  changes.
	 */
	if (jmscott_rename(active_path, archive_path) < 0)
		die2("rename(active->archive) failed", strerror(errno));
	int fd_archive = fd_active;
	fd_active = -1;

	/*
	 *  Get the mode of the now archived file to set for the new active.
	 */
	if (jmscott_fstat(fd_archive, &st) < 0)
		die2("fstat(archive) failed", strerror(errno));

	/*
	 *  Recreate new active file
	 */
	fd_active = jmscott_open(
			active_path,
			O_CREAT | O_TRUNC | O_WRONLY,
			st.st_mode
	);
	if (fd_active < 0) {
		if (errno != EEXIST)
			die2("open(new active) failed", strerror(errno));
		/*
		 *  The new active was created by another process, so insure
		 *  new active still regular.
		 */
		if (jmscott_fstat(fd_active, &st) == 0) {
			/*
			 *  Another process created new active of different file
			 *  type.
			 */
			if (!S_ISREG(st.st_mode))
				die("new active not regular file");
		} else
			die2("fstat(new active) failed", strerror(errno));
		exit_status = EXIT_NEW_EXISTS;
	}

	//  reset mode of new active to mode of original active

	if (jmscott_fchmod(fd_active, st.st_mode))
		die2("fchmod(active) failed", strerror(errno));

	if (jmscott_close(fd_archive))
		die2("close(archive) failed", strerror(errno));
	if (jmscott_close(fd_active))
		die2("close(active) failed", strerror(errno));
	_exit(exit_status);
}
