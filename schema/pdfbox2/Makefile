#
#  Synopsis:
#	Makefile suitable for single machine development.
#  Note:
#	Need to define CLASSPATH elswhere
#
include ../schema.mk
include ../../local.mk

JCOMPILED=								\
	putPDDocument.class

all: $(JCOMPILED)

clean:
	rm -f $(JCOMPILED)

dev-links:
	test -e lib || ln -s . lib
	test -e sbin || ln -s . sbin
	test -e log || ln -s . log
	test -e etc || ln -s . etc
	test -e run || ln -s . run

putPDDocument.class:  putPDDocument.java
	javac -cp $(PDFBOX_APP2_JAR) putPDDocument.java

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
		-d $(PDFBOX2_PREFIX)/log
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
		rummy.sql						\
		schema.sql						\
		unmerged-tsv_utf8.sql					\
		$(PDFBOX2_PREFIX)/lib

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(PROGS)						\
		append-pgtexts-brr					\
		cron-append-pgtexts-brr					\
		cron-merge-json						\
		merge-extract_utf8					\
		merge-pddocument					\
		wait-utf8-byte_count					\
		$(PDFBOX2_PREFIX)/sbin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ug=rx		\
		Makefile						\
		putPDDocument.java					\
		$(PDFBOX2_PREFIX)/src
distclean:
	rm -rf $(PDFBOX2_PREFIX)/lib
	rm -rf $(PDFBOX2_PREFIX)/src
	rm -rf $(PDFBOX2_PREFIX)/sbin

frisk ff:
	flowd frisk pdfbox2.flow.example
