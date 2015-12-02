#
#  Synopsis:
#	Makefile suitable for single machine development.
#  Note:
#	Need to define CLASSPATH elswhere
#
include ../schema.mk
include ../../local.mk

COMPILED=merge-stdin-tsv_utf8
PROGS=merge-stdin-tsv_utf8

CLASSPATH:=.:/usr/local/lib/pdfbox-app-2.jar
JCOMPILED=								\
	putPDDocument.class

all: $(JCOMPILED) $(COMPILED)

clean:
	rm -f $(JCOMPILED) $(COMPILED) merge-stdin-tsv_utf8.c

merge-stdin-tsv_utf8: merge-stdin-tsv_utf8.pgc ../../common.c
	ecpg merge-stdin-tsv_utf8.pgc
	$(CC) $(CFLAGS) -I$(PGINC) merge-stdin-tsv_utf8.c 		\
		-o merge-stdin-tsv_utf8 -L$(PGLIB) -lecpg
	rm merge-stdin-tsv_utf8.c

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc
	test -e run || ln -s . run

putPDDocument.class:  putPDDocument.java
	javac -cp $(CLASSPATH) putPDDocument.java

install: all
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/lib
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/sbin
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/src
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/log
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/spool
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/run
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/tmp
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/etc

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ug=rx		\
		$(JCOMPILED)						\
		merge-json-extract_utf8.sql				\
		merge-json-pddocument.sql				\
		pdfbox2.flow.example					\
		profile.example						\
		schema.sql						\
		$(PDFBOX2_PREFIX)/lib

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(PROGS)						\
		cron-merge-json						\
		extract_utf82pg						\
		pddocument2pg						\
		$(PDFBOX2_PREFIX)/sbin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ug=rx		\
		Makefile						\
		merge-stdin-tsv_utf8.pgc				\
		putPDDocument.java					\
		$(PDFBOX2_PREFIX)/src
distclean:
	rm -rf $(PDFBOX2_PREFIX)/lib
	rm -rf $(PDFBOX2_PREFIX)/src
	rm -rf $(PDFBOX2_PREFIX)/sbin

frisk ff:
	flowd frisk pdfbox2.flow.example
