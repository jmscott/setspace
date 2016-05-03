/*
 *  Synopsis:
 *	Is a stream of records a well formed set of sha1 udigs?
 *  Description:
 *	Is the stream a set of sha udigs?  No udig appears more than once in the
 *	set and no order of elements is assumed.
 *  Exit:
 *  	0	-> is a sha udig set
 *  	1	-> is not a sha udig set
 *	2	-> is empty
 *  	64	-> system error occured
 */

#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

#define NEW_UDIG		1
#define SCAN_ALGORITHM_h	2
#define SCAN_ALGORITHM_a	3
#define SCAN_ALGORITHM_colon	4
#define SCAN_DIGEST		5
#define SCAN_NEW_LINE		6

static char *prog =	"is-udig-sha-set";
static char *newline =	"\n";

#define IS_HEX(c)	(('0' <=(c)&&(c)<='9') || ('a' <=(c)&&(c) <= 'f'))

/*
 *  Size of hash table.  Really ought to grow dynamically.
 */
#define HASH_TABLE_SIZE		999359

/*
 *  Attributed to Dan Berstein from a usenet comp.lang.c newsgroup.
 */
static unsigned int
djb(unsigned char *buf, int nbytes)
{
	unsigned int hash = 5381;
	unsigned char *p;

	p = buf;
	while (--nbytes >= 0)
		 hash = ((hash << 5) + hash) + *p++;
	return hash;
}

struct element
{
	char		*sha;
	struct element	*next;
};

static struct element	*table[HASH_TABLE_SIZE] = {0};

static void
die(char *msg)
{
	static char ERROR[] = ": ERROR: ";
	write(2, prog, strlen(prog));
	write(2, ERROR, strlen(ERROR));
	write(2, msg, strlen(msg));
	write(2, newline, strlen(newline));
	exit(255);
}

static void
die2(char *msg1, char *msg2)
{
	char buf[BUFSIZ + 1];

	strncpy(buf, msg1, BUFSIZ);
	strncat(buf, ": ", BUFSIZ - strlen(buf));
	strncat(buf, msg2, BUFSIZ - strlen(buf));
	die(buf);
}

static int
_read(char *buf, int size)
{
	int nbytes;

again:
	nbytes = read(0, buf, size);
	if (nbytes >= 0)
		return nbytes;
	if (errno == EINTR)
		goto again;
	die2("read() failed", strerror(errno));
	/*NOTREACHED*/
	return -1;		/*  silence compiler */
}

/*
 *  Add udig to set of seen udigs.
 */
static void
add_sha(char *sha)
{
	unsigned int hash;
	struct element *u;

	hash = djb((unsigned char *)sha, 40) % HASH_TABLE_SIZE;
	u = table[hash];
	while (u) {
		/*
		 *  UDig already seen, so this is not a set.
		 */
		if (strcmp(u->sha, sha) == 0)
			exit(1);
		u = u->next;
	}
	/*
	 *  SHA not found, so allocate a new one.
	 */
	u = malloc(sizeof *u);
	if (u == NULL)
		die2("malloc(element) failed", strerror(errno));
	u->sha = malloc(strlen(sha) + 1);
	if (u->sha == NULL)
		die2("malloc(sha) failed", strerror(errno));
	strcpy(u->sha, sha);
	u->next = 0;

	if (table[hash])
		u->next = table[hash];
	table[hash] = u;
}

int
main()
{
	char buf[BUFSIZ];
	int state;
	char digest[40], *dp;
	char *b_end = 0;
	int nbytes;

	state = NEW_UDIG;
	while ((nbytes = _read(buf, sizeof buf)) > 0) {
		char *b;

		b = buf;
		b_end = buf + nbytes;

		while (b < b_end) {
			char c;

			c = *b++;

			switch (state) {

			/*
			 *  New sha udig always starts with character 's'
			 */
			case NEW_UDIG:
				if (c != 's')
					exit(1);
				state = SCAN_ALGORITHM_h;
				break;
			/*
			 *  Scan character 'h'.
			 */
			case SCAN_ALGORITHM_h:
				if (c != 'h')
					exit(1);
				break;
			/*
			 *  Scan character 'a'.
			 */
			case SCAN_ALGORITHM_a:
				if (c != 'a')
					exit(1);
				state = SCAN_ALGORITHM_colon;
				break;
			/*
			 *  Scan a colon character.
			 */
			case SCAN_ALGORITHM_colon:
				if (c != ':')
					exit(1);
				state = SCAN_DIGEST;
				dp = digest;
				break;
			/*
			 *   Scan up to 40 hex characters.
			 */
			case SCAN_DIGEST:
				if (!IS_HEX(c))
					exit(1);
				*dp++ = c;
				if (dp - digest == 40)
					state = SCAN_NEW_LINE;
				break;

			case SCAN_NEW_LINE:
				if (c != '\n')
					exit(1);
				*dp = 0;
				add_sha(digest);
				state = NEW_UDIG;
				break;
			}
		}
	}
	if (state != NEW_UDIG)
		exit(1);
	exit(b_end ? 0 : 2);
}
