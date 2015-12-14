/*
 *  Synopsis:
 *	Atomically flip either a fifo->regular or regular->fifo files
 *
 *  Usage:
 *  	flip-tail file spool/route/file_mime_pdf			\
 *  					spool/route/file_mime_pdf.12345
 *  	flip-tail fifo spool/route/file_mime_pdf 			\
 *  					spool/route/file_mime_pdf.1234
 *  	flip-tail file spool/setspace.brr setspace-1439576646.brr
 *
 *  Description:
 *	Occasionally for a fifo we want to restart the reader process without
 *	blocking the writer process.  Consider two flowd processes connected
 *	over a one-way fifo.  If we stop the reader then the writer blocks until
 *	the reader restarts. In high traffic environments such blockage can be
 *	problematic.  flip-tail will atomically transform the fifo into a
 *	regular file, where the inbound writes will accumlate in file and not
 *	block the writer.  After rebooting the reader, then flip back to fifo.
 *
 *  Arguments:
 *  	new-type	fifo or file
 *  	path		path to active file/fifo that will be rolled
 *  	rename-path	rename active file to this path
 *
 *  Exit Status:
 *  	0	success, the new file was created and was of the requested type
 *  	1	new file already exists
 *  	2	new file exists but was not the requested type
 *	3	wrong number of arguments
 *	4	unexpected file type, expected "file" or "fifo" 
 *	5	file open() failed
 *	6	file rename() failed
 *	7	file creat() failed
 *	8	file mkfifo() failed
 *	9	file fstat() failed
 *	10	file close() failed
 *	11	file fchmod(new) failed
 *
 *  Blame:
 *  	jmscott@setspace.com
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>

#include <errno.h>
#include <string.h>
#include <stdio.h>

static char	progname[] = "flip-tail";

#define EXIT_SUCCESS	0
#define EXIT_NEW_EXIST	1
#define EXIT_NEW_DIFF	2
#define EXIT_BAD_ARGC	3
#define EXIT_BAD_FILETYPE	4
#define EXIT_BAD_OPEN	5
#define EXIT_BAD_RENAME	6
#define EXIT_BAD_CREAT	7
#define EXIT_BAD_MKFIFO	8
#define EXIT_BAD_FSTAT	9
#define EXIT_BAD_CLOSE	10
#define EXIT_BAD_FCHMOD	11

#define COMMON_NEED_DIE2
#define COMMON_NEED_OPEN
#define COMMON_NEED_CLOSE
#define COMMON_NEED_FCHMOD

#include "common.c"

int
main(int argc, char **argv)
{
	char *path, *rename_path;
	int fd_old, fd_new;
	int exit_status = EXIT_SUCCESS;
	char *type;
	struct stat st;

	if (argc != 4)
		die2(EXIT_BAD_ARGC, "wrong number of arguments", "expected 3");

	type = argv[1];
	if (strcmp(type, "file") != 0 && strcmp(type, "fifo") != 0)
		die2(EXIT_BAD_FILETYPE, "unknown file type", type);

	path = argv[2];
	rename_path = argv[3];

	/*
	 *  Open an existing, active file, preventing deletion of the underlying
	 *  inode.
	 */
	fd_old = _open(path, O_WRONLY, 0);

	/*
	 *  Rename the old path, effectively hiding the inode (not the path)
	 *  from further writes.  Remember what ever is reading the file
	 *  (usually flowd) won't actually flip until the inode - not the
	 *  path - changes.
	 */
	if (rename(path, rename_path) < 0)
		die2(EXIT_BAD_RENAME, "rename(old, new) failed",
					strerror(errno));
	/*
	 *  Get the mode of old file to set for the new file.
	 */
	if (fstat(fd_old, &st) < 0)
		die2(EXIT_BAD_FSTAT, "fstat(old) failed", strerror(errno));

	/*
	 *  Recreate a new, tailable file that is either a regular file or
	 *  a fifo.  type[2] == 'l' => type=="file";  otherwise type == "fifo".
	 */
	if (type[2] == 'l') {
		fd_new = creat(path, st.st_mode);
		if (fd_new < 0) {
			if (errno != EEXIST)
				die2(EXIT_BAD_CREAT, "creat(new) failed",
								strerror(errno)
				);
			exit_status = EXIT_NEW_EXIST;
		}
	} else {
		fd_new = mkfifo(path, st.st_mode);
		if (fd_new < 0) {
			if (errno != EEXIST)
				die2(EXIT_BAD_MKFIFO,
					"mkfifo(new) failed",
					strerror(errno)
				);
			exit_status = EXIT_NEW_EXIST;
		}
	}
	_fchmod(fd_new, st.st_mode);

	/*
	 *  Insure that the new file is of the requested type, since another
	 *  process, like append-brr, also opens with O_CREAT, creating a race
	 *  condition.
	 */
	if (exit_status == EXIT_NEW_EXIST) {
		/*
		 *   Is the new file not the same type as the old
		 */
		if (fstat(fd_new, &st) == 0) {
			mode_t m = st.st_mode;

			/*
			 *  A panicy situation the caller needs to know about.
			 */
			if (!S_ISREG(m) && !S_ISFIFO(m))
				die2(EXIT_BAD_FILETYPE,
					"new file is neither fifo nor regular",
					path
				);

			if ((type[2] == 'l' && !S_ISREG(m)) ||
			    (type[2] == 'f' && !S_ISREG(m)))
				exit_status = EXIT_NEW_DIFF;
		} else
			die2(EXIT_BAD_FSTAT, "fstat(new) failed",
						strerror(errno)
			);
	}
	/*
	 *  Close files
	 */
	if (fd_old > -1)
		_close(fd_old);
	if (fd_new > -1)
		_close(fd_new);
	_exit(exit_status);
}
