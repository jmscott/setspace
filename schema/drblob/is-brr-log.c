/*
 *  Synopsis:
 *	Is a stream of data a well formed brr log file: yes or no or empty?
 *  Description:
 *  	A blob request record log file consists of lines of ascii text
 *  	with 7 tab separated fields matching
 *
 *		start time: YYYY-MM-DDTHH:MM:SS.NS9(([-+]hh:mm)|Z)
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
 *		byte count: 0 <= 2^63 - 1
 *		\t
 *		wall duration: sec.ns where
 *			       0<=sec&&sec <= 2^31 -1 && 0<=ns&&ns <=999999999
 *  Exit:
 *  	0	-> is a brr log
 *  	1	-> is not a brr log
 *	2	-> is empty
 *  	32	-> system fault
 *  Blame:
 *  	jmscott@setspace.com
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

	exit(32);
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
 *  Verify that a range of characters in a string are in a 
 *  set.  If a char is not in the set, then exit this process falsely;
 *  otherwise, reset the source pointer to first char not in the set.
 */
static void 
in_range(char **src, int upper, int lower, char *set)
{
	char *s, *s_end;

	s = *src;
	s_end = s + upper;
	while (s < s_end) {
		char c = *s++;

		if (strchr(set, c) != NULL)
			continue;
		if (s - *src <= lower)	//  too few characters
			exit(1);
		--s;
		break;
	}
	*src = s;
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
 *  Match RFC3339Nano time stamp:
 *
 *	2010-12-03T04:47:05.123456789+00:01
 *	2010-12-03T04:47:05.123456789-00:03
 *	2010-12-03T04:47:05.123456789Z
 */
static void
scan_rfc399nano(char **src)
{
	char *p = *src;

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
	 *	match T[012][0-9]
	 */
	if (*p++ != 'T')
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
	in_range(&p, 9, 1, digits);

	switch (*p++) {
	case 'Z':
		break;
	case '+': case '-':
		in_set(&p, 2, digits);
		if (*p++ != ':')
			exit(1);
		in_set(&p, 2, digits);
		break;
	default:
		exit(1);
	}
	if (*p++ != '\t')
		exit(1);
	*src = p;
}

/*
 *  Scan the network flow field which matches this perl5 regex:
 *
 *	[a-z][a-z0-9]{0,7}([[:graph:]{1,128})
 */
static void
scan_network_flow(char **src)
{
	char c, *p = *src;

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
	*src = p;
}

/*
 *  Blobio verb: get|put|give|take|eat|what.
 */
static char *
scan_verb(char **src)
{
	char c, *p = *src, *verb;

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
	*src = p;
	return verb;
}
/*
 *  Scan the uniform digest that looks like:
 *
 *  	algorithm:hash-digest
 */
static void
scan_udig(char **src)
{
	char *p = *src;

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
	*src = p;
}

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
 *  Scan the chat history, verifying the reposnse
 *  is correct for the verb.
 */
static void
scan_chat_history(char *verb, char **src)
{
	char *p, *q, ch[9], v1, v2;
	int len;

	p = *src;
	q = p;

	scan_set(&q, 8, "nok,");
	len = q - p;
	if (len < 2)
		exit(1);
	memcpy(ch, p, len);
	p = q;
	ch[len] = 0;
	v1 = verb[0];
	v2 = verb[1];

	/*
	 *  Only verbs: get/put/eat/wrap/roll ca
	 *  Remember, the chat history is the observed value during the
	 *  network flow from the server's point of view.
	 */
	if (strcmp("no", ch) == 0 || strcmp("ok", ch) == 0)
		goto done;

	/*
	 *  Both "give" and "take" can chat either "ok,ok" or "ok,no"
	 */
	if (strcmp("ok,ok", ch) == 0 || strcmp("ok,no", ch) == 0) {
		if ((v1 == 'g' && v2 == 'i') || v1 == 't')
			goto done;
		exit(1);
	}
	/*
	 *  Only a "take" can do "ok,ok,ok" or "ok,ok,no".
	 */
	if ((strcmp("ok,ok,ok",ch)==0 || strcmp("ok,ok,no", ch)==0) && v1=='t')
		goto done;
	exit(1);
done:
	if (*p++ != '\t')
		exit(1);
	*src = p;
}

/*
 *  Scan for an unsigned int <= 2^63 -1.
 *
 *  Note:
 *  	Need a compile time pragma to insure the
 *
 *  		sizeof long long int == 8
 *
 *  	is true.
 */
static void
scan_uint63(char **src, char c_end)
{
	char *p, *q;
	long long v;

	p = *src;
	q = p;

	scan_set(&p, 21, digits);

	errno = 0;
	v = strtoll(q, (char **)0, 10);

	if ((v == LLONG_MAX && errno == ERANGE) ||
	    (LLONG_MAX > 9223372036854775807 &&
	     v > 9223372036854775807))
		exit(1);
	if (*p++ != c_end)
		exit(1);
	*src = p;
}

/*
 *  Duration: seconds.nsecs, where seconds ~ /^\{1,9}$/
 *  	      and nsecs ~ /^\d{9}$/
 *  	      and seconds <= 2147483647
 */
static void
scan_duration(char **src, char c_end)
{
	char *p, *q;
	long v;

	p = *src;
	q = p;

	scan_set(&p, 10, digits);

	errno = 0;
	v = strtoll(q, (char **)0, 10);

	if ((v == LONG_MAX && errno == ERANGE) ||
	    (LONG_MAX > 2147483647 && v > 2147483647))
		exit(1);
	if (*p++ != '.')
		exit(1);
	in_range(&p, 9, 1, digits);
	if (*p++ != c_end)
		exit(1);
	*src = p;
}

int
main()
{
	char buf[10 * 1024], *p;
	char *verb;
	int read_input = 0;

	/*
	 *  Note:
	 *	Please replace with read().
	 */
	while (fgets(buf, sizeof buf, stdin)) {
		read_input = 1;

		p = buf;

		//  start time of request
		scan_rfc399nano(&p);
		scan_network_flow(&p);
		verb = scan_verb(&p);

		scan_udig(&p);
		scan_chat_history(verb, &p);

		//  byte count
		scan_uint63(&p, '\t');

		//  wall duration
		scan_duration(&p, '\n');

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
