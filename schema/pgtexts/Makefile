#
#  Synopsis:
#	Development makefile
#  Note:
#	PostgreSQL program ecpg must be in PATH
#
include ../schema.mk
include ../../local.mk

COMPILED=merge-stdin-tsv_utf8
PROGS=merge-stdin-tsv_utf8

all: $(COMPILED)
clean:
	rm -f $(COMPILED) merge-stdin-tsv_utf8.c

merge-stdin-tsv_utf8: merge-stdin-tsv_utf8.pgc ../../common.c
	ecpg merge-stdin-tsv_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-tsv_utf8.c 		\
		-o merge-stdin-tsv_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-tsv_utf8.c
