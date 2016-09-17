#
#  Synopsis:
#	Development makefile
#  Note:
#	PostgreSQL program ecpg must be in PATH
#
include ../schema.mk
include ../../local.mk

COMPILED=merge-stdin-tsv_utf8 merge-stdin-text_utf8
PROGS=									\
	merge-stdin-text_utf8						\
	merge-stdin-tsv_utf8						\
	merge-text_utf8							\
	merge-tsv_utf8

all: $(COMPILED)
clean:
	rm -f $(COMPILED) merge-stdin-tsv_utf8.c

merge-stdin-tsv_utf8:							\
		merge-stdin-tsv_utf8.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-tsv_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-tsv_utf8.c		\
			-o merge-stdin-tsv_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-tsv_utf8.c

merge-stdin-text_utf8:							\
		merge-stdin-text_utf8.pgc				\
		../../common.c						\
		../../common-ecpg.c
	ecpg merge-stdin-text_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-text_utf8.c		\
			-o merge-stdin-text_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-text_utf8.c

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc

install: all
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/lib
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/sbin
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/bin
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/src
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/log
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/spool
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/run
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/log
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/tmp
	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER)			\
		-d $(PGTEXTS_PREFIX)/etc

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m ug=rx		\
		profile.example						\
		pgtexts.flow.example					\
		rummy.sql						\
		schema.sql						\
		$(PGTEXTS_PREFIX)/lib

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m u=rx		\
		$(PROGS)						\
		$(PGTEXTS_PREFIX)/sbin

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m u=rx		\
		goog2fts						\
		$(PGTEXTS_PREFIX)/sbin

	install -g $(PGTEXTS_GROUP) -o $(PGTEXTS_USER) -m ug=rx		\
		Makefile						\
		merge-stdin-tsv_utf8.pgc				\
		$(PGTEXTS_PREFIX)/src

distclean:
	rm -rf $(PGTEXTS_PREFIX)/lib
	rm -rf $(PGTEXTS_PREFIX)/src
	rm -rf $(PGTEXTS_PREFIX)/sbin

frisk ff:
	flowd frisk pgtexts.flow.example
