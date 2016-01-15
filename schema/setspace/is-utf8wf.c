/*
 *  Synopsis:
 *	Is standard input a well formed (RFC3629) UTF-8 byte stream
 *  Usage:
 *  	is-utf8wf <BLOB
 *  Exit Status:
 *	0	if all bytes match utf8 rfc3629
 *	1	some bytes do not comply to utf8 state machine
 *	2	stream is empty
 *	3	read error
 *	4	wrong number of arguments
 *  Blame:
 *  	jmscott@setspace.com
 *  Note:
 *	Some interesting "pure", table driven state machine algorithms exist.
 *	For example, these links describe utf8 state recognizers that expect
 *	entire strings as input before processing:
 *
 *	       http://lists.w3.org/Archives/Public/www-archive/2009Apr/0001.html
 *	       http://bjoern.hoehrmann.de/utf-8/decoder/dfa/
 *
 *	SInce this program is byte/stream oriented, the above algorithms would
 *	need to be modified if used here.
 *
 *	And, while you are exploring, be sure to read perl's mighty
 *	unicode/set spanner packages that built the decoders described above:
 *
 *		http://search.cpan.org/dist/Unicode-SetAutomaton/
 *		http://search.cpan.org/dist/Set-IntSpan-Partition/
 *
 *	An invalid utf8 page is here:
 *
 *		http://www.cl.cam.ac.uk/~mgk25/ucs/examples/UTF-8-test.txt
 */

static char progname[] = "is-utf8wf";
#define EXIT_OK		0
#define EXIT_BAD_U8	1
#define EXIT_EMPTY	2
#define EXIT_BAD_READ	3
#define EXIT_BAD_ARGC	4

#define COMMON_NEED_READ

#include "../../common.c"

/*
 *  States of scanner.
 */
#define STATE_START	0	/* goto new code sequence */

#define STATE_2BYTE2	1	/* goto second byte of 2 byte sequence */

#define STATE_3BYTE2	2	/* goto second byte of 3 byte sequence */
#define STATE_3BYTE3	3	/* goto third byte of 3 byte sequence */

#define STATE_4BYTE2	4	/* goto second byte of 4 byte sequence */
#define STATE_4BYTE3	5	/* goto third byte of 4 byte sequence */
#define STATE_4BYTE4	6	/* goto fourth byte of 4 byte sequence */

/*
 *  Bit masks up to 4 bytes per character
 */
#define B00000000	0x0
#define B10000000	0x80
#define B11000000	0xC0
#define B11100000	0xE0
#define B11110000	0xF0
#define B11111000	0xF8

int
main(int argc, char **argv)
{
	unsigned char buf[4096];
	int nread;
	unsigned char *p_end = 0;
	int state = STATE_START;
	unsigned int code_point = 0;

	if (argc != 1)
		die(EXIT_BAD_ARGC, "wrong number of arguments");
	(void)argv;

	while ((nread = _read(0, buf, sizeof buf)) > 0) {
		unsigned char *p;

		p = buf;
		p_end = buf + nread;

		while (p < p_end) {

		unsigned char c = *p++;

		switch (state) {
		case STATE_START:
			/*
			 *  Single byte/7 bit ascii?
			 *  Remain in START_START.
			 */
			if ((c & B10000000) == B00000000)
				break;

			/*
			 *  Mutibyte code point.
			 */
			code_point = 0;
			if ((c & B11100000) == B11000000) {
				/*
				 *  Start of 2 byte/11 bit sequence, so shift
				 *  the lower 5 bits of the first byte left
				 *  6 bits.
				 */
				code_point = (c & ~B11100000) << 6;
				state = STATE_2BYTE2;
			} else if ((c & B11110000) == B11100000) {
				/*
				 *  Start of 3 byte/16 bit sequence, so shift
				 *  the lower 4 bits of the first byte left 12
				 *  bits.
				 */
				code_point = (c & ~B11110000) << 12;
				state = STATE_3BYTE2;
			} else if ((c & B11111000) == B11110000) {
				/*
				 *  Start of 4 byte/21 bit sequence, so shift
				 *  the lower 3 bits of the first byte left 18
				 *  bits.
				 */
				code_point = (c & ~B11111000) << 18;
				state = STATE_4BYTE2;
			} else
				_exit(EXIT_BAD_U8);
			break;
		/*
		 *  Expect the second and final byte of two byte/11 bit
		 *  code point.
		 */
		case STATE_2BYTE2:
			/*
			 *  No continuation byte implies malformed sequence.
			 */
			if ((c & B11000000) != B10000000)
				_exit(EXIT_BAD_U8);
			/*
			 *  Or in the lower 6 bits of the second & final byte.
			 */
			code_point |= (c & ~B11000000);

			/*
			 *  Is an overlong representation.  Any value less than
			 *  128 must be represented with a single byte/7 bits.
			 */
			if (code_point < 128)
				_exit(EXIT_BAD_U8);

			state = STATE_START;
			break;
		/*
		 *  Expect the second byte of a three byte sequence.
		 */
		case STATE_3BYTE2:
			/*
			 *  No continuation byte implies malformed sequence.
			 */
			if ((c & B11000000) != B10000000)
				_exit(EXIT_BAD_U8);
			/*
			 *  Or in the lower 6 bits of the second byte into
			 *  bits 12 through 7 of the code point.
			 */
			code_point |= (c & ~B11000000) << 6;

			state = STATE_3BYTE3;
			break;

		/*
		 *  Third byte of three byte/16 bit sequence.
		 */
		case STATE_3BYTE3:
			/*
			 *  No continuation byte implies malformed sequence.
			 */
			if ((c & B11000000) != B10000000)
				_exit(EXIT_BAD_U8);
			/*
			 *  Or in the lower 6 bits of the third & final byte
			 *  into bits 6 through 1 of the code point.
			 */
			code_point |= c & ~B11000000;

			/*
			 *  Is an overlong representation?  Any value less than
			 *  2048 must be represented with either a
			 *  one byte/7 bit or two byte/11 bit sequence.
			 *
			 *  Second test is for UTF-16 surrogate pairs.
			 */
			if (code_point < 2048 ||
			    (0xD800 <= code_point&&code_point <= 0xDFFF))
				_exit(EXIT_BAD_U8);
			state = STATE_START;
			break;
		/*
		 *  Expect the second byte of four byte/21 bit sequence
		 */
		case STATE_4BYTE2:
			/*
			 *  No continuation byte implies malformed sequence.
			 */
			if ((c & B11000000) != B10000000)
				_exit(EXIT_BAD_U8);
			/*
			 *  Or in the lower 6 bits of the second byte into
			 *  bits 18 through 13 of the code point.
			 */
			code_point |= (c & ~B11000000) << 12;
			state = STATE_4BYTE3;
			break;
		/*
		 *  Expect the third byte of four byte/21 bit sequence
		 */
		case STATE_4BYTE3:
			/*
			 *  No continuation byte implies malformed sequence.
			 */
			if ((c & B11000000) != B10000000)
				_exit(EXIT_BAD_U8);
			/*
			 *  Or in the lower 6 bits of the third byte into
			 *  bits 12 through 7 of the code point.
			 */
			code_point |= (c & ~B11000000) << 6;
			state = STATE_4BYTE4;
			break;
		/*
		 *  Expect the fourth byte of four byte/21 bit sequence
		 */
		case STATE_4BYTE4:
			/*
			 *  No continuation byte implies malformed sequence.
			 */
			if ((c & B11000000) != B10000000)
				_exit(EXIT_BAD_U8);
			/*
			 *  Or in the lower 6 bits of the fourth byte into
			 *  bits 6 through 1 of the code point.
			 */
			code_point |= c & ~B11000000;
			/*
			 *  Is an overlong representation.  Any value less than
			 *  65536 must be represented with either a
			 *  one byte/7 bit, two byte/11 bit or three byte/16
			 *  sequence.
			 */
			if (code_point < 65536)
				_exit(EXIT_BAD_U8);
			state = STATE_START;
			break;
		}}
	}
	if (state == STATE_START)
		_exit(p_end ? EXIT_OK : EXIT_EMPTY);
	_exit(EXIT_BAD_U8);
}
