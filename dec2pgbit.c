/*
 *  Synopsis:
 *	Convert a list of byte decimal values into postgres bit(256) cast.
 *  Usage:
 *	echo 10 | dec2pgbitmap
 *	dec2pgbitmap <<END
 *	11
 *	12
 *	13
 *	14
 *	END
 *	B'111'::bit(256) >> 244
 *  Blame:
 *  	jmscott@setspace.com
 *  	setspace@gmail.com
 *  Note:
 *  	Error handling code is atrocious.
 */

#include <stdio.h>
#include <stdlib.h>

int
main()
{
	int byte, b_min, b_max;
	int i;
	unsigned char bitmap[256] = {0};

	b_max = 0;
	b_min = 256;
	while (scanf("%d\n", &byte) > 0) {
		if (byte < 0 || byte > 255) {
			fprintf(stderr, "decimal not >= 0 || < 256: %d\n",
					byte);
			exit(1);
		}
		if (b_min > byte)
			b_min = byte;
		if (b_max < byte)
			b_max = byte;
		bitmap[255 - byte] = 1;
		if (feof(stdin))
			break;
	}
	putchar('B');
	putchar('\'');

	//  no bits set
	if (b_max == 0) {
		puts("0'::bit(256)");
		exit(0);
	}

	//  write compact bit string
	for (i = b_min;  i <= b_max;  i++)
		putchar(bitmap[255 - i] == 0 ? '0' : '1');
	printf("'::bit(256) >> %d\n", 255 - b_max);
	exit(0);
}
