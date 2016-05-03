/*
 *  Synopsis:
 *	Is a stream of records a well formed set of udigs?
 *  Description:
 *	Is the stream a set of udigs?  No udig appears more than once in the
 *	set and no order of elements is assumed.
 *  Exit:
 *  	0	-> is a udig set
 *  	1	-> is not a udig set
 *	2	-> is empty
 *  	64	-> system error occured
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	When a false set is seen, the input is not drained.
 *	Should SIGPIPE be caught?
 */

#include <string.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <unistd.h>

#define NEW_UDIG	1
#define SCAN_ALGORITHM	2
#define SCAN_DIGEST	3

#define UDIG_BUF	15 + 1 + 255 + 1 + 1

static char *prog =	"is-udig-set";
static char *newline =	"\n";

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
	char		*udig;
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
	exit(64);
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
add_udig(char *udig)
{
	unsigned int hash;
	struct element *u;

	hash = djb((unsigned char *)udig, strlen(udig)) % HASH_TABLE_SIZE;
	u = table[hash];
	while (u) {
		/*
		 *  UDig already seen, so this is not a set.
		 */
		if (strcmp(u->udig, udig) == 0)
			exit(1);
		u = u->next;
	}
	/*
	 *  UDig not found, so allocate a new one.
	 */
	u = malloc(sizeof *u);
	if (u == NULL)
		die2("malloc(element) failed", strerror(errno));
	u->udig = malloc(strlen(udig) + 1);
	if (u->udig == NULL)
		die2("malloc(udig) failed", strerror(errno));
	strcpy(u->udig, udig);
	u->next = 0;

	if (table[hash])
		u->next = table[hash];
	table[hash] = u;
}

int
main()
{
	/*
	 *  Maximum size of a udig: algorithm + : + digest + newline + null.
	 */
	char buf[BUFSIZ];
	int state;
	char udig[UDIG_BUF];
	char *b_end = 0;
	int nbytes;
	char *colon_p;

	state = NEW_UDIG;
	while ((nbytes = _read(buf, sizeof buf)) > 0) {
		char *b, *u;

		b = buf;
		b_end = buf + nbytes;

		while (b < b_end) {
			char c;

			c = *b++;
			if (c != '\n' && !isgraph(c))
				exit(1);

			switch (state) {
			/*
			 *  Expect the start of a new udig.
			 */
			case NEW_UDIG:
				/*
				 *  Scan the first character
				 */
				if (c == '\n')
					exit(1);
				if (c == ':')
					exit(1);
				u = udig;
				colon_p = 0;
				*u++ = c;
				state = SCAN_ALGORITHM;
				break;
			/*
			 *  Saw a graphical char that is NOT a colon,
			 *  so start scanning the digest algorithm portion
			 *  of the udig, which must be 1-16 characters in
			 *  length.
			 */
			case SCAN_ALGORITHM:
				if (c == '\n' || u - udig > 15)
					exit(1);
				*u++ = c;
				if (c == ':') {
					colon_p = u;
					state = SCAN_DIGEST;
				}
				break;
			/*
			 *  Scanning the digest, which, after the first colon,
			 *  can contain any graphical char.  A new line
			 *  terminates the udig.
			 */
			case SCAN_DIGEST:
				if (c == '\n') {
					*u = 0;
					add_udig(udig);
					state = NEW_UDIG;
				} else if (colon_p - udig > 255)
					exit(1);
				*u++ = c;
				break;
			}
		}
	}
	if (state != NEW_UDIG)
		exit(1);
	exit(b_end ? 0 : 2);
}
