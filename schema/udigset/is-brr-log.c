/*
 *  Synopsis:
 *	Is a stream of data a well formed brr log file: yes or no or empty?
 *  Description:
 *  	A blob request record log file consists of lines of ascii text
 *  	with 7 tab separated fields
 *  	where the f
 *  	match the following pattern:
 *
 *		start time: YYYY-MM-DD HH:MM:SS.NS9 [-+]ZZZZ
 *		\t
 *		netflow: matches perl5 re:
 *
 *			[a-z][a-z0-9]{,7}~[[:graph:]]{1,128})
 *
 *		\t
 *		verb: get|put|give|take|eat|wrap|roll
 *		\t
 *		udig: [a-z][a-z0-9]{7}:hash-digest{1,128}
 *		\t
 *		chat history:
 *			ok|no			all verbs
 *
 *			ok,ok|ok,no		when verb is "give" or "take"
 *
 *			ok,ok,ok|ok,ok,no	only "take"
 *		\t
 *		byte count: signed 64 bit >= 0 && <= 2^63 - 1
 *		\t
 *		wall duration: sec.ns where
 *			       0<=sec&&sec <= 2^31 -1 && 0<=ns&&ns <=999999999
 *  Exit:
 *  	0	-> is a brr log
 *  	1	-> is not a brr log
 *	2	-> is empty
 *  	255	-> system fault
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *	Would be nice to remove dependency upon stdio library.
 */

#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include <limits.h>

#define NEW_UDIG	1
#define SCAN_ALGORITHM	2
#define SCAN_DIGEST	3

#define TZ_CHAR(c)	(isalnum(c) || (c)=='/' || (c) == '-')
#define TZ_MAX_SIZE	32

#define UDIG_BUF	8 + 1 + 128 + 1 + 1

static char *prog =	"is-brr-log";
static char digits[] = "0123456789";
static char lower_alnum[] = "abcdefghijklmnopqrstuvwxyz0123456789";

/*
 *  ASCII graphical characters:
 */
static char graph_set[] =
		"!\"#$%&'()*+,-./"	//  0x32 -> 0x47
		"0123456789:;<=>?"	//  0x48 -> 0x63
		"@ABCDEFGHIJKLMNO"	//  0x64 -> 0x79
		"PQRSTUVWXYZ[\\]^_"	//  0x50 -> 0x5f
		"`abcdefghijklmno"	//  0x60 -> 0x6f
		"pqrstuvwxyz{|}~"	//  0x70 -> 0x7e
;

static void
die(char *msg)
{
	static char ERROR[] = ": ERROR: ";
	static char *newline =	"\n";

	write(2, prog, strlen(prog));
	write(2, ERROR, strlen(ERROR));
	write(2, msg, strlen(msg));
	write(2, newline, strlen(newline));

	exit(255);
}

/*
 *  Verify that exactly the first 'n' characters in a string are in a 
 *  set.  If a char is not in the set, then exit this process falsely;
 *  otherwise, reset the source pointer to src + n;
 */
static void 
in_set(char **src, int n, char *set)
{
	char *s, *s_end;

	s = *src;
	s_end = s + n;
	while (s < s_end) {
		char c = *s++;

		if (c == 0 || strchr(set, c) == NULL)
			exit(1);
	}
	*src = s_end;
}

/*
 *  Scan up to 'limit' chars that are in set
 *  and set src to first char not in the set.
 *  Null in the 'src' fails.
 */
static void 
scan_set(char **src, int limit, char *set)
{
	char *s, *s_end;

	s = *src;
	s_end = s + limit;
	while (s < s_end) {
		char c = *s;

		if (c == 0)
			exit(1);
		if (strchr(set, c) == NULL)
			break;
		s++;
	}
	*src = s;
}

/*
 *  Verify that all characters up to but not including c_end are in the
 *  character set.  If a char is not in the set, then exit this process falsely;
 *  otherwise, reset the source pointer to the position of the character
 *  after c_end.
 */
static void 
in_set2char(char **src, int n, char c_end, char *set)
{
	char *s, *s_end;

	s = *src;
	s_end = s + n;
	while (s < s_end && *s != c_end) {
		char c = *s++;

		if (c == 0 || strchr(set, c) == NULL)
			exit(1);
	}
	/*
	 *  Insure we ended on the c_end character.
	 */
	if (s == s_end && *s == c_end)
		*src = s + 1;
	else
		exit(1);
}

int
main()
{
	char buf[10 * 1024], c, *p, v1, v2;
	char *verb, ch[9];
	int len;
	int read_input = 0;

	/*
	 *  Note:
	 *	Please replace with read().
	 */
	while (fgets(buf, sizeof buf, stdin)) {
		read_input = 1;

		p = buf;

		/*
		 *  Match time stamp, typically like:
		 *
		 *	2010-12-03 04:47:05 +0000
		 */

		/*
		 *  Year:
		 *	match [2345]YYY
		 */
		if ('2' > *p || *p > '5')
			exit(1);
		p++;
		in_set(&p, 3, digits);

		/*
		 *  Month:
		 *	match -[01][0-9]
		 */
		if (*p++ != '-')
			exit(1);
		if (*p != '0' && *p != '1')
			exit(1);
		p++;
		if ('0' > *p || *p > '9')
			exit(1);
		p++;

		/*
		 *  Day:
		 *	match -[0123][0-9]
		 */
		if (*p++ != '-')
			exit(1);
		if ('0' > *p || *p > '3')
			exit(1);
		p++;
		if ('0' > *p || *p > '9')
			exit(1);
		p++;

		/*
		 *  Hour:
		 *	match [ ][012][0-9]
		 */
		if (*p++ != ' ')
			exit(1);
		if ('0' > *p || *p > '2')
			exit(1);
		p++;
		if ('0' > *p || *p > '9')
			exit(1);
		p++;

		/*
		 *  Minute:
		 *	match :[0-5][0-9]
		 */
		if (*p++ != ':')
			exit(1);
		if ('0' > *p || *p > '5')
			exit(1);
		p++;
		if ('0' > *p || *p > '9')
			exit(1);
		p++;

		/*
		 *  Second:
		 *	match :[0-5][0-9]
		 */
		if (*p++ != ':')
			exit(1);
		if ('0' > *p || *p > '5')
			exit(1);
		p++;
		if ('0' > *p || *p > '9')
			exit(1);
		p++;
		if (*p++ != '.')
			exit(1);
		in_set(&p, 9, digits);

		/*
		 *  Scan for timezone offset: [+-]\d\d\d\d
		 */
		if (*p++ != ' ')
			exit(1);
		if (*p != '+' && *p != '-')
			exit(1);
		p++;
		in_set2char(&p, 4, '\t', digits);

		/*
		 *  Scan the network flow field which matches this perl5 regex:
		 *
		 *	[a-z][a-z0-9]{0,7}([[:graph:]{1,128})
		 */
		c = *p++;
		if ('a' > c || c > 'z')
			exit(1);

		scan_set(&p, 7, lower_alnum);
		if (*p++ != '~')
			exit(1);
		scan_set(&p, 128, graph_set);
		if (*p++ != '\t')
			exit(1);

		/*
		 *  Blobio verb: get|put|give|take|eat|what.
		 */
		c = *p++;
		if (c == 'g') {			/* get|give */
			c = *p++;
			if (c == 'e') {			/* get */
				if (*p++ != 't')
					exit(1);	/* give */
				verb = "get";

			} else if (c == 'i') {
				if (*p++ != 'v' || *p++ != 'e')
					exit(1);
				verb = "give";
			} else
				exit(1);
		} else if (c == 'p') {		/* put */
			if (*p++ != 'u' || *p++ != 't')
				exit(1);
			verb = "put";
		} else if (c == 't') {		/* take */
			if (*p++ != 'a' || *p++ != 'k' || *p++ != 'e')
				exit(1);
			verb = "take";
		} else if (c == 'e') {		/* eat */
			if (*p++ != 'a' || *p++ != 't')
				exit(1);
			verb = "eat";
		} else if (c == 'w') {		/* wrap */
			if (*p++ != 'r' || *p++ != 'a' || *p++ != 'p')
				exit(1);
			verb = "wrap";
		} else if (c == 'r') {		/* roll */
			if (*p++ != 'o' || *p++ != 'l' || *p++ != 'l')
				exit(1);
			verb = "roll";
		} else
			exit(1);
		if (*p++ != '\t')
			exit(1);

		/*
		 *  Scan the uniform digest that looks like:
		 *
		 *  	algorithm:hash-digest
		 */

		/*
		 *  First char of algorithm must be lower case alpha.
		 */
		if ('a' > *p || *p > 'z')
			exit(1);
		p++;
		/*
		 *  Up to 7 alphnum chars before colon.
		 */
		scan_set(&p, 7, lower_alnum);

		/*
		 *  Expect colon between algorithm and digest.
		 */
		if (*p++ != ':')
			exit(1);	/* first char in algo not : */

		scan_set(&p, 128, graph_set);

		if (*p++ != '\t')
			exit(1);

		/*
		 *  Chat History:
		 *	ok		->	verb in {get,put,eat,wrap,roll}
		 *	ok,ok		->	verb in {give}
		 *	ok,ok,ok	->	verb in {take}
		 *	no		->	verb in	{
		 *					get,put,eat,
		 *					give,take,
		 *					wrap,roll
		 *				}
		 *	ok,no		->	verb in {give,take}
		 *	ok,ok,no	->	verb in {take}
		 *
		 *  All chat histories start with character 'o' or 'n'.
		 */
		/*
		 *  Scan the chat history, verifying the reposnse
		 *  is correct for the verb.
		 */
		{
			char *q = p;

			scan_set(&q, 8, "nok,");
			len = q - p;
			if (len < 2)
				exit(1);
			memcpy(ch, p, len);
			p = q;
			ch[len] = 0;
			v1 = verb[0];
			v2 = verb[1];
		}

		/*
		 *  Only verbs: get/put/eat/wrap/roll ca
		 *  Remember, the chat history is the observed value during the
		 *  network flow from the server's point of view.
		 */
		if (strcmp("no", ch) == 0 || strcmp("ok", ch) == 0)
			goto scan_byte_count;

		/*
		 *  Both "give" and "take" can chat either "ok,ok" or "ok,no"
		 */
		if (strcmp("ok,ok", ch) == 0 || strcmp("ok,no", ch) == 0) {
			if ((v1 == 'g' && v2 == 'i') || v1 == 't')
				goto scan_byte_count;
			exit(1);
		}
		/*
		 *  Only a "take" can do "ok,ok,ok" or "ok,ok,no".
		 */
		if ((strcmp("ok,ok,ok",ch)==0 || strcmp("ok,ok,no", ch)==0) &&
		    v1 == 't')
			goto scan_byte_count;
		exit(1);
scan_byte_count:
		if (*p++ != '\t')
			exit(1);
		/*
		 *  Byte Count
		 *
		 *  Scan for <= 21 digits and verify the integer value
		 *  <= 2^63 - 1.
		 *
		 *  Note:
		 *  	Need a compile time pragma to insure the
		 *
		 *  		sizeof long long int == 8
		 *
		 *  	is true.
		 */
		{
			char *q = p;
			long long v;

			scan_set(&p, 21, digits);

			errno = 0;
			v = strtoll(q, (char **)0, 10);

			if ((v == LLONG_MAX && errno == ERANGE) ||
			    (LLONG_MAX > 9223372036854775807 &&
			     v > 9223372036854775807))
				exit(1);
		}

		/*
		 *  Request Duration: seconds.nsecs, where seconds ~ /^\{1,9}$/
		 *  		      and nsecs ~ /^\d{9}$/
		 *  		      and seconds <= 2147483647
		 */
		if (*p++ != '\t')
			exit(1);
		{
			char *q = p;
			long v;

			scan_set(&p, 10, digits);

			errno = 0;
			v = strtoll(q, (char **)0, 10);

			if ((v == LONG_MAX && errno == ERANGE) ||
			    (LONG_MAX > 2147483647 && v > 2147483647))
				exit(1);
		}
		if (*p++ != '.')
			exit(1);
		in_set2char(&p, 9, '\n', digits);
	}
	if (ferror(stdin))
		die("ferror(stdin) returned true");
	if (read_input)
		exit(feof(stdin) ? 0 : 1);

	/*
	 *  Empty set.
	 */
	exit(2);
}
