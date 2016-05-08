#
#  Synopsis:
#	Makefile suitable for single machine development.
#  Note:
#	Need to define CLASSPATH elswhere
#
include ../schema.mk
include ../../local.mk

JCOMPILED=								\
	ExtractPagesUTF8.class						\
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
	javac -cp $(PDFBOX2_APP_JAR) putPDDocument.java

ExtractPagesUTF8.class:  ExtractPagesUTF8.java
	javac -cp $(PDFBOX2_APP_JAR) ExtractPagesUTF8.java

#ExtractKeywords.class:  ExtractKeywords.java
	#javac -cp $(PDFBOX2_APP_JAR):$(PDFBOX2_XMP_JAR) ExtractKeywords.java

install: all
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/lib
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/sbin
	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER)			\
		-d $(PDFBOX2_PREFIX)/bin
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

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ug=r		\
		$(JCOMPILED)						\
		pdfbox2.flow.example					\
		pdfq-keyword.sql					\
		profile.example						\
		rummy.sql						\
		schema.sql						\
		$(PDFBOX2_PREFIX)/lib

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(PROGS)						\
		append-page-pgtexts-brr					\
		append-pgtexts-brr					\
		cron-append-pgtexts-brr					\
		merge-extract_pages_utf8				\
		merge-pddocument					\
		$(PDFBOX2_PREFIX)/sbin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m u=rx		\
		$(PROGS)						\
		cat-pages-utf8						\
		pdfq							\
		$(PDFBOX2_PREFIX)/bin

	install -g $(PDFBOX2_GROUP) -o $(PDFBOX2_USER) -m ugo=r		\
		Makefile						\
		ExtractKeywords.java					\
		ExtractPagesUTF8.java					\
		putPDDocument.java					\
		$(PDFBOX2_PREFIX)/src
distclean:
	rm -rf $(PDFBOX2_PREFIX)/lib
	rm -rf $(PDFBOX2_PREFIX)/src
	rm -rf $(PDFBOX2_PREFIX)/sbin

frisk ff:
	flowd frisk pdfbox2.flow.example
